---
title: "COOT: Combined Offline or Online Testing"
date: 2023-03-02
draft: true
summary: 'Test flakiness is the greatest scourge of continuous delivery'
---

# Motivation

Test flakiness is the greatest scourge of continuous delivery(CD) pipelines. Slow pipelines and a lack of automated tests can be hugely unpleasant, but nothing slows feature delivery more than flakiness. Slow pipes and manual testing can be planned around, but flakiness prevents predictability in result timing and removes confidence in those results. It changes the pipeline from a tool for delivery to yet another source of entropy foiling delivery.

![An American coot swimming, its red eye catching the light](/images/coot/coot-red-gaze.jpg)

*A coot fixes its terrifying red gaze on flakiness*

Flakiness can come from any non-deterministic dependency of a test: time of day, unreliable startup of underlying components, the hardware it's running on, timing between UI components and the network, and on and on and on. COOT attempts to remove [external services](#what-is-an-external-service) as a source of flakiness.

Almost any non-trivial app depends on an external service to do its work and it likely depends on multiple. There's a tension between test reliability and realism when an external service is involved. We want to test directly against the external service to find out if our requests and its responses match expectations. When we directly contact that external service as part of the test, that contact is by nature flaky: we can no longer tell if a failure is from the expectation mismatch we want to catch as opposed to a networking failure or temporary downtime in the external service or any other reason. We have to examine the result to see if it's a "true" failure or an incidental one. If it is an incidental failure, that means we still don't know if our test would pass or not if the incidental failure were removed.

![A coot upended in the water, head submerged and tail in the air](/images/coot/coot-offline-mode.jpg)

*A coot in offline mode*

A common way to deflake external services is by recording interactions with them in one test run and then replaying them in subsequent runs. [VCR](https://github.com/vcr/vcr) popularized this approach in Ruby and we use [VCR.py](https://vcrpy.readthedocs.io/en/latest/) in some of our Python tests. This makes tests reliable but at a significant cost in realism. The recordings make the assumption that the behavior at the time of the recording never changes, which is the opposite of what's happening in any system under development!

COOT increases the realism of our tests while maintaining their reliability. It still uses the two stage VCR technique:

1. It records network interactions while a test is running aka online tests
2. It replays those network interactions in subsequent runs aka offline tests

Most importantly, it runs stage 1 opportunistically against a shared environment each time that environment changes. If that succeeds, it updates the recordings. The latest recordings are replayed in all CD builds. That keeps network outages in CD builds or issues in the shared environment from affecting the CD flow, but also prevents the recordings from getting woefully out of date.

# Architecture

![A mounted bird skeleton in a museum display case](/images/coot/coot-skeleton.jpg)

## Basic Flow

In every scenario, COOT uses [mountebank](https://www.mbtest.org/) to record and replay responses.

How it runs those test's is up to the test runner itself. For our Python integration tests, it'll use pytest. For browser testing, we've started using [Playwright](https://playwright.dev/). Playwright's auto-wait and user-visible locators are another way we're attempting to reduce flake, in this case the flake introduced by previous generations of browser-based testing tools.

When running an online test, it:

1. Starts a [proxy impostor](https://www.mbtest.org/docs/api/proxies) for each external service used by the app under test
2. Configures the app to talk to its impostor rather than the external service
3. Runs the test, recording the responses from the external service and relaying them back to the app
4. Makes requests through the stack, keeping the responses from the external service in memory while relaying them back to the app
5. Writes the responses to disk if the test passes

![Online recording mode: the test runner starts mountebank with a proxy to HS Proxy, configures IDSB Portal to talk to it, executes the test case through Playwright, then tells mountebank to write the recordings](/images/coot/online-recording-mode.png)

*(All diagrams from Lucidchart)*

When running an offline test, COOT:

1. Starts a mountebank impostor from the responses written in the online test
2. Configures the app to talk to its impostor rather than the external service
3. Runs the test, replaying responses to the app

![Offline playback mode: the test runner starts mountebank with recorded responses, configures IDSB Portal to talk to it, and executes the test case through Playwright](/images/coot/offline-playback-mode.png)

## Run Locations

COOT runs on developer laptops and in GitHub Actions in offline and online modes in both locations.

### Developer Laptops and GitHub Actions Offline

When making a change to already tested code locally or testing a change in a GitHub Actions CD workflow, COOT is run in offline mode. It doesn't talk to external services at all and only replays recordings.

### Developer Laptops Online

When adding a new feature or working with a new external service, a developer runs COOT in online mode against the external service. They include the new recordings in their PR and those are used as the baseline for the CD workflow and updating the recordings as the service changes.

When debugging an error or working with other services developed by our teams, the developer runs COOT in a hybrid online/offline mode. They can turn on recorded imposters for some services while configuring the app to talk directly to other services. Those services can be remote or an "external" service that the developer is running on their laptop to debug or develop. COOT doesn't care how recording, replay, or direct communication is configured; it leaves it to the developer to pick a combination that works for their purpose.

### GitHub Actions Online

Whenever a new version of an external service of an application with COOT tests is released to production, the production release GitHub Action triggers the online COOT tests in their own GitHub Action production. If the external service is one developed by a different organization or company, we run the COOT tests on a schedule e.g. daily for any that depend on HealthSource.

Up to two versions of the COOT tests run: the version of the application in production and the version of the application on main. If those versions are identical, only one COOT run is performed.

If the COOT run fails on the application version currently in production, an alert is raised for the team that owns the external service. If the COOT run fails on the application version currently on main, an alert is raised for the application's team. If both tests pass and there are changes to the recordings, a PR is created to update the recordings.

![GitHub Actions online flow: merging a PR that affects HS Proxy deploys it to prod, which starts COOT online test workflows for both the prod and main revisions of idsb-portal; failures page or Slack the owning team, and if both pass the recordings are updated by PR](/images/coot/github-actions-online-flow.png)

# Alternatives

## Update Recordings Against Staging

We're proposing COOT test and update its recordings from production. This is because staging is currently behind a VPN. Ways to get around that:

* We could have GitHub Actions connect to the VPN, but that introduces flake in a dependency between COOT and the VPN.
* We could run COOT in k8s in the staging cluster itself, but that adds a second mode to run COOT besides GitHub Actions and requires an additional mechanism to get the recordings back from k8s to the repo.

We prefer production as a result.

## Store Recordings Separately from the Repo

We're proposing storing the COOT recordings alongside the test. They could be large and doing that requires that COOT make commits against the repo to update them. We could instead store the recordings externally e.g. in an S3 bucket. That would require developers and GHA to have access to that bucket to run the tests and would break the determinism of the recordings being versioned in git along with the tests. We prefer the repo as a result.

See [the dedupe future COOT](#future-coots) for a way to reduce the size.

# Future COOTs

The architecture proposed here is what we're starting with. Here are some directions COOT could be taken:

* COOT records full responses now, but it only records enough of the request to identify matching requests for replay. We could record more of the request and use it to do [pact-style contract testing](https://pact.io/). This would let the "external services" developed by other teams at Datavant use the COOT recordings to check if they're going to break a client before releasing.
* COOT records from production now. We could also record in staging and playback both.
* COOT runs tests against applications isolated in developer laptops or GitHub Actions now. We could run COOT against staging or production apps to canary releases or perform uptime or performance checks.
* COOT records a lot of duplicate responses. We could add some logic to combine responses into minimized versions expanded by [mountebank templating](https://www.mbtest.org/docs/commandLine#config-files) or use [behaviors](https://www.mbtest.org/docs/api/behaviors) to further share responses.
* COOT assumes a synchronous record/response model for the applications it's testing. We have many services that perform batch jobs or other asynchronous processing. We could trigger callbacks and ask services to simulate processing steps to bring COOT to those scenarios.

# Appendix

## What is an "external service"?

When COOT talks about an "external" service, it means anything the application needs to perform the test that isn't deterministically created in the environment local to the test. That means multiple server processes and webapps and databases and so on could be "internal" services for COOT, they just need to be reliably created as part of the test.

In the opinion of the authors of COOT, as many things that can be "internal" and run reliably and quickly with the test should be i.e. COOT should record and replay as few things as needed to reduce flake. Everything that's played back from a recording reduces the realism of the test and increases the probability of a divergence that lets a bug slip through.

If there are several services in a single repository or set of repositories, this raises the question of if they should be started with the application under test or if they should be treated as external. Deciding this requires weighing the startup speed, resource usage, and reliability of those services against the realism mentioned above, so our answer is the classic engineer's "it depends".

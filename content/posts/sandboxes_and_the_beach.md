---
title: "Sandboxes and the Beach"
date: 2025-03-17
draft: false
summary: 'What can you do with infinite sand?'
---

Let's say you're a sand castle enthusiast. Though "enthusiast" doesn't truly capture your level of sand mania. You spend a significant portion of your waking hours every week devising sand sculptures of greater and greater complexity.

Your ambitions have long outstripped what a single sand enthusiast can accomplish, so you belong to a team of like minded individuals. That team similarly moved past what a single group can accomplish and has linked up with several more teams with a similar bent. These teams now occupy a good portion of the beach, adding to and refining their sand colossus.

In the early days, everyone did their building on the beach. The sand's already there and the beach is a nice place to be, right? No, the beach is not a nice place to be, not when you're pushing the limits of sand. The general public loves the beach, too, and storms rip through all the time. Any sand structure built there needs to be ready to face the world. The whole endeavor nearly collapsed as teams attempted to bridge experimental designs into a unified whole under the assault of the outside world.

What saved the project? Sandboxes. People started prototyping new designs in personal sandboxes. They even made devices to simulate the depredations of weather and human visitors on these prototypes. They'd test theories in the small and then make molds to recreate them in full size on the beach. The controlled environment lets them try more things more quickly and shake out obvious problems.

Still, you have to take those designs to the beach eventually to receive the accolades of your peers. Being able to perfect a design in the sandbox made it far less likely it'd fail on the beach, but it could still crumble to nothing when its attachment to the whole didn't align. Even more frightening, those failures endangered the whole structure.

One team started Project MEGASANDBOX to solve this. An old stadium had come up for sale, they bought it and painstakingly recreated the beach in it. Each team would then recreate their structures in MEGASANDBOX and everyone would be able to see how their designs interacted before taking them to the beach.

It was too popular! Everyone was trying their half-completed designs in MEGASANDBOX and that made it more volatile than the beach. The team behind it doubled down and started Project YOTTASANDBOX, a MEGASANDBOX per sand sculptor. Last we heard, they're still out there, buying up every old stadium that hits the market.

You and your team just wanted to get new designs out on the beach, so you went back to your personal sandboxes to figure out a way. The problems on the beach always appeared at the attachment from a new design to what already existed. The more connections there were, the harder it was to line everything up.

That led to your next attempt: what if we could recreate just the attachment points in the sandbox? Then you can check that it lines up while you're working on it but you don't need the full beach to do it. We've reached a good degree of stability with that, or as much stability as one can reach building on sand.

# Why do you want me to read this weird story about sand?

The allegory above is contorted so much in the shape of software engineering that it hardly qualifies as an allegory. Still, it's probably worth being explicit in what it implies for developing systems:

1. The more you can test locally and in CI/CD, the more quickly you can iterate
   1. The more verisimilitude you have locally, the more those tests can show. Laptops are fast enough to spin up and destroy a Postgres db for every test run. Localstack can give you a decent idea of what will happen when you talk to AWS.
2. Boundary crossing into other teams' systems is the hardest thing to test locally, so we should minimize it while making it as testable as possible. That means exposing explicit APIs and only going through those to other systems.
   1. This also pushes the sweet spot of the size of a system up from a microservice to something more meaty. Since we want to have clear API boundaries between standalone services, making microservices of things that are deployed together makes us overpay that tax.
   2. Publishing fakes and contract tests can be a great way to let other teams develop more effectively against what you've created.
3. Staging and other shared non-prod environments become more and more impossible as the number of teams increase. The nature of developing a service is instability: you develop a change till it's stable. Anything in development in staging is at least slightly broken till it's ready to deploy. If you're using other teams' in-development changes, you'll be exposed to their changes. This gets worse and worse the more teams you have in an environment.
   1. Ephemeral environments are affected by the same forces. Creating a working environment from scratch is always challenging. Getting many going simultaneously increases that challenge non-linearly.
4. Even with diligence in designing for local testing, sometimes you need to verify how things work when deployed. AWS services are unpredictable, Kubernetes is complicated, and the internet is vast. Rather than having a complete staging environment to do that, you can deploy a shadow service to prod. Have requests and data flow to both it and your live service, but only use the responses from the live service. Prod is reality and being able to safely check behavior there gives a confidence that isn't reachable in a simulated environment.

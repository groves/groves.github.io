---
title: "Sharing is Invaluable, Sharing is Expensive"
date: 2023-05-07
draft: false
summary: 'How to decide when sharing is caring'
---

Tools for sharing code fill the software world. Package managers, mono and polyrepos, semantic versioning, and on and on, a good portion of what we talk about in developing software is how to share. Because of the value gained from shared code and the ubiquity of sharing tools, it can feel like any code that can be shared should be shared. There are tradeoffs to sharing though. That makes the answer to the question of if you should share "it depends", as with every other question in software development.

# Sharing Benefits

Sharing is so well understood to be great in software that it feels foolish to call out reasons why. We do that here because calling out the specific places where its most powerful can help in deciding if a particular case will use that power.

## The Shoulders of Giants

The increase in capability of software we can build today compared to 40 years ago can be attributed as much to shared code as it can to Moore's law. The enormous cost of building an operating system or database or programming language can be amortized over an even more enormous number of users continuously making the baseline more capable.

## Helping Others Help You

Inside a company, sharing infrastructure and underlying libraries allows platform teams to make life easier for application teams. Everyone deploying to Kubernetes lets the IDE team put all their effort into making it great, and the more people run React and Fastapi, the more the AppSec team can build tools to make those libraries safe by default.

## Consistency

When we want to present a unified face, either in a UI or in an implementation of tokenization, sharing the code to do it can make that easier.

# Sharing Drawbacks

## Generic is More Complicated Than Specific

Sharing something makes it support multiple use cases. Each additional use case adds complications to the code, more so with more difference between the uses.

This is not a one time cost. Each change in the future requires the author to consider all the use cases. If other users stop using the shared functionality, the cost to make it generic was wasted.

## Changing Needs Coordination

### AKA Mo Versions Mo Problems

When changing shared code, the author must test that code with each user to keep from breaking them. If they want to make a breaking change, they have to bump a version and leave work for the user to update later. Even bumping the version of dependencies in shared code can be breaking, leading to work cascading across teams.

## Indirect is Harder than Direct

Using shared code means that your code goes through a reference or package to get to the shared code. That indirection makes many things harder: viewing the code, grepping across the codebase, editing it, updating it.

## Sharing Adds Tools

To publish, use, or edit shared code, you use tools like package managers and repositories. Adding shared code that your team works on means everyone must learn these tools.

# Considerations

Given the above benefits and drawbacks, here are some things to consider when deciding when and how to share.

## Default to Shared for Anything Below Your Application

For things that are below your application code and don't truly affect your product's use cases, default to shared to help others help you. Have a strong, product driven reason to use a database other than Postgres or a backend language other than Python. Even with that, think thrice.

## The Rate of Change is a Factor of the Cost of Sharing

In the heat of product discovery the use cases we're supporting change as often as the code itself. Attempting to share across two products that are figuring out what they want to be is like trying to stand with feet split between the hoods of two speeding cars. Even if the drivers are well coordinated, you're going to have to do some fancy footwork. If one driver takes a left, good luck!

That also means that if one product has built something that a second product might use, factoring that out into a shared library can be far cheaper if it's done when the first product is stable.

## Conway's law Rules Everything Around Me

Coordination is another major factor in the cost of sharing. A single team is already coordinating internally. The cost of sharing across products or services owned by one team doesn't include learning and keeping up to date on the use cases of other teams.

## If Sharing is Expensive, Giving is Free

The cost of making things generic and coordination comes from using the same code in multiple places. `cp -r` gives another team your code without incurring any of those costs. Of course, in addition to removing the costs of sharing, giving also removes any of the ongoing benefits of sharing.

However if the code significantly diverges after the copy, there wouldn't have been any benefits anyway. A powerful way to start sharing can be to make a copy and then pull the parts that didn't diverge up into a shared library.

## The Friction of Sharing Encourages Convergence

For things we want to stay in sync across teams like UI styling, that it's harder to change shared code can be a feature. It both pushes to have as little in those shared layers as possible and incents teams to use what's in there as is more than if they could easily change it.

## Shares Determine Savings

The implementation savings in sharing come from the number of times something is reused minus the additional cost of making it sharable. If something is only going to be reused once, it's way less likely to pay off than if it's going to be reused 10 times.

## Divergence Determines Cost

The more simple and similar the use cases of a library are, the easier it is to make generic. If each user needs to configure it differently, that difference in use multiplies the difficulty of coming up with commonalities.

# How to Decide

Those considerations lead to these factors to consider:

* How well understood is the use case i.e. what is the rate of change likely to be
* Is there a clear owner that has a grasp of all the use cases i.e. are we attempting to violate Conway's Law
* Do we need future updates, or could we just start from the current code and fork i.e. can we give freely instead of sharing expensively?
* How many uses will there be of the shared functionality?
* Are those uses similar enough to truly share?

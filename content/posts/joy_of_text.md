---
title: "Joy of Text"
date: 2022-08-24
draft: false
summary: 'Own your tools'
---

Text goes back nearly to the beginning of computing.
As soon as we could move past binary, we added it.
Despite huge advances in what we can display, it's stuck around as a primary interface.
It efficiently conveys information and requires minimal capabilities to produce and display.

That combination, information density and ease of creation, make text an ideal software development substrate.
It enables the creation of usable, powerful tools while not being so complex as to discourage the developer from modifying them or creating their own.
Using it for display encourages tools that the developer can truly own, customizing and enhancing them as they learn.

# Imagining a software development workshop
To contrast with integrated development environments(IDEs) that are the norm for software development today, we can imagine a collection of text-centric tools making a development workshop.
In a physical workshop, tools can be used individually or they can be used in concert for more complex jobs.
In a woodshop, it's common to build a jig to turn a complicated or impossible cut into an easy and repeatable one.

Moving from an IDE to text tools allows allows software development to happen in that workshop style instead of a hermetically sealed environment.
An IDE gains functionality by completely consuming a project: its compiler, dependencies, tests, packaging, execution, and so on.
By controlling everything, the IDE is able integrate everything and produce a deep, unified view of the project.
The requirement for that is steep: all aspects of the project must be understood by the IDE in the forms it expects.

A text workshop doesn't need that depth of integration.
Editing, [file finding][fzf], and [search][ripgrep] work without integration.
The same command-line based build tooling that continuous integration uses can be used in the workshop.
Using the [Language Server Protocol][] a text-based editor  can take have the same deep code understanding that IDEs have.

[fzf]: https://github.com/junegunn/fzf
[ripgrep]: https://github.com/BurntSushi/ripgrep
[Language Server Protocol]: https://microsoft.github.io/language-server-protocol/

Importantly, it can do this piecemeal.
Rather than having to consume the whole project, it's functional with no specific knowledge of the project and can add independent functionality as it's useful.
The below sections imagine tools that allow that stacking of functionality in this workshop style.

## Terminal as workbench
A workbench is the heart of a workshop.
The piece being worked on is brought to the bench along with all the tools necessary for the work.
In text-centric development, the terminal is our workbench.

Terminals have a [venerable history][vt history] and a [midden of features][control sequences] to attest to that.
We don't need the majority of those.
For our purposes, we need terminals to support two extremes in types of programs:
1. Ones that emit a stream of text that the terminal draws in a scrolling pane
2. Ones that draw characters at x, y coordinates the program specifies, taking over the pane

[vt history]: https://vt100.net/dec/vt_history
[control sequences]: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html

The first type contains programs that immediately send their results to standard output.
Language manuals often start with [a simple program of this type][hello world].
That simplicity makes the type perpetually useful, as it allows quick creation of tools.
Despite that ease, single-task programs like a compiler or server often don't need more user interface features than this.
They can even [precisely style their output][rich] without giving up the ease of creation.


[hello world]: http://helloworldcollection.de/
[rich]: https://github.com/Textualize/rich#readme

The second type contains programs that draw a full user interface and update it over time.
We need it for our editor, be it Vim, Emacs, or [whatever you like][helix].
By using the terminal's rows and columns of characters as an updatable canvas, we can interactively edit files.

[helix]: https://helix-editor.com/

## Bringing multiple tools to the workbench

Beyond supporting these kinds of text tools, we also need to be able to use multiple tools simultaneously.
[Modern terminal emulators][kitty] allow the [creation and layout][kitty layout] of multiple terminal panes in a single OS window.
[Terminal multiplexers][tmux] allow the same thing in terminal emulators that don't support it natively.
Using multiple terminal panes managed by either of these systems lets us bring multiple text-based tools to a shared "workbench".

[kitty]: https://sw.kovidgoyal.net/kitty/
[kitty layout]: https://sw.kovidgoyal.net/kitty/overview/#layouts
[tmux]: https://github.com/tmux/tmux/wiki

With this workbench approach, we can have an editor in one pane, a shell for running the compiler in a second, and a script running the server we're developing showing its logs in a third.
Through the [scripting exposed by the terminal][kitty scripting] we can bind a keystroke to [reexecute the last command run in a shell][reterm] without leaving our editor pane.

[kitty scripting]: https://sw.kovidgoyal.net/kitty/kittens/custom/#using-kittens-to-script-kitty-without-any-terminal-ui
[reterm]: https://github.com/groves/catherd/blob/6c4c98a5289d56f7fad55f060a03929ede35a3b3/reterm.py#L39

By using the terminal as our workbench, we create a uniform interface for manipulating our tools.
Everything is a rectangle of text and can be handled at a high-level by the interfaces of the terminal.
This uniformity lets us build simple tools that can be combined at these higher levels.

## Using tools in concert

[That scripting][kitty scripting] goes from [extracting the text in a pane][OSC 52],
to [sending data back to the controlling terminal][OSC 7],
to placing and creating panes based on that text and data.
Because the system is entirely composed of text in panes, it allows access and control over everything in the environment.

[OSC 52]: https://terminalguide.namepad.de/seq/osc-52/
[OSC 7]: https://wezfurlong.org/wezterm/shell-integration.html#osc-7-escape-sequence-to-set-the-working-directory

For example, if our tests are being run in one pane, we could run a script on the output of the command execution.
That script would know the directory and project type based on terminal control codes emitted by the shell.
From the project type, it'd be able to map stack trace lines in a test failure to source files in the directory.
It could then open an editor pane for each of the top three stack frames, showing the context of the failure through the stack.

## Bring your workbench to the execution environment
Because it's been around since the early days, text as a medium works as a lowest common denominator of execution environments.
Whether we're working on our local laptop, on a server through SSH, in a Docker container, or in a Docker container on a server through [Mosh][] over [Tailscale][], all the text tools run equally well.
An iPad with an external keyboard can be as effective as a laptop to develop remotely.

[mosh]: https://mosh.org/
[tailscale]: https://tailscale.com/

If you define your workbench and all its tools with [Home Manager][] in [Nix][] you can package the tools for an arbitrary instruction set in an arbitrary format.
Compile them for Arm processors as a Docker layer and place that on top of the container you want to run.
Or [SCP the tools and their full dependencies][nix-copy-closure] to anything you can SSH into.

[home manager]: https://github.com/nix-community/home-manager
[nix]: https://nixos.org/explore.html
[nix-copy-closure]: https://nixos.org/manual/nix/stable/command-ref/nix-copy-closure.html

By being pure text, there are far fewer restrictions on where we can run our tools.
That lets us run them in the most convenient place for the project instead of contorting the project to run alongside the tools.

## Blit when better
While text can be pushed surprisingly far in conveying information, there are things that are clearer as an image.
If we want to display an image from our workbench, [modern terminals enable that][kitty graphics].
Because the data is being transmitted through the terminal stream, it doesn't matter what we have between our local environment and where the image data lives:
as long as we can get text through, we can get the image data through.

[kitty graphics]: https://sw.kovidgoyal.net/kitty/graphics-protocol/

This terminal escape hatch works for arbitrary types of data.
If the execution environment wants the local environment to open a URL or to transfer a file, it can request that.
Drilling through the terminal stream to the local environment allows us to use all the surrounding chrome.

# Why not VS Code

In the latest Stack Overflow developer editor usage survey, 
almost [75% of developers use VS Code][editor popularity survey] and 
[81% of them love it][editor love survey].
It can do everything described for the workbench above,
including [bringing the editor to the execution environment][VS Code remote development].

[editor popularity survey]: https://survey.stackoverflow.co/2022/#section-most-popular-technologies-integrated-development-environment
[editor love survey]: https://survey.stackoverflow.co/2022/#section-most-loved-dreaded-and-wanted-integrated-development-environment
[VS Code remote development]: https://code.visualstudio.com/docs/remote/remote-overview

Given its ubiquity and capabilities and the genuine affection it engenders, 
why fight the tide of developer tooling to keep antiquated technology?
For me, it's to have a chance of truly owning the tools I use, and through that finding joy in their use.

[VS Code's src directory][VS Code src] has over 1 million lines of text in it.
That's just the core editor, not counting the multitude of plugins that make it sing.
It's built on Electron, which pulls in the complexity of the entire browser stack.

[VS Code src]: https://github.com/microsoft/vscode/tree/main/src

By contrast, [Helix], my preferred editor has 40 thousand lines of text in [its source directories][Helix GitHub].
Kitty, my terminal of choice, has 80 thousand lines of text in [its source directory][Kitty GitHub].
Their combined 120 thousand lines of text are an order of magnitude less than what's in VS Code,
and probably two orders of magnitude when you include Electron and plugins.

[Helix GitHub]: https://github.com/helix-editor/helix
[Kitty GitHub]: https://github.com/kovidgoyal/kitty/tree/master/kitty

These numbers aren't meant to be an absolute accounting of the complexity of these projects.
Instead I think they serve as a proxy for the ease of making changes and customizations.
There's nothing more personal in development than the environment in which you work.
The size of these text tools makes me excited to customize them for my workshop, not daunted.

In [this interview][changelog Vim episode], Gary Bernhardt talks about his 15 years of Vim use:

[changelog Vim episode]: https://changelog.com/podcast/450#transcript-124

> At the beginning of that time, TextMate was just becoming popular.
> Then it was Sublime Text was cool.
> Then Atom was cool. Then VS Code was cool.
> A lot of people switched between two of those, three of those, maybe all four of those,
> and that whole time I was just getting better and better and better at Vim.
> And you multiply that out by the length of a career, you use Vim for 40 years - 
> you’re gonna be so good at it by the end, and it’s still gonna be totally relevant.

Helix builds on my own 20 years of Vim use.
Kitty builds on my equally long love affair with the command line.
Being able to build on them to make an environment that uniquely suits me has me more excited to write code than I've been in years.
---
title: "Joy of Text"
date: 2021-10-12T18:03:33-04:00
draft: true
summary: 'Own your tools'
---

Text goes back nearly to the beginning of computing.
As soon as we could move past raw binary, we added it.
Despite huge advances in what we can display, text has stuck around as a primary interface.
Text efficiently conveys information and requires minimal capabilities to produce and display.

That combination, information density and ease of creation, make it an ideal software development substrate.
It enables the creation of usable, powerful tools while not being so complex enough to discourage the developer from modifying them or creating their own.
Using text for display encourages tools that the developer can truly own, customizing and enhancing them as they learn.

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
Using the [Language Server Protocol][] it can take have the same deep code understanding that IDEs have.

[fzf]: https://github.com/junegunn/fzf
[ripgrep]: https://github.com/BurntSushi/ripgrep
[Language Server Protocol]: https://microsoft.github.io/language-server-protocol/

Importantly, it can do this piecemeal.
Rather than having to consume the whole project, it's functional with no specific knowledge of the project and can add independent functionality as it's useful.
The below sections imagine tools that allow that stacking of functionality in this workshop style.

## Context visible and navigable automatically
A workbench is the heart of a workshop.
The piece being worked on is brought to the bench along with all the tools necessary for the work.
In text-centric development, the terminal is our workbench.

[Modern terminal emulators][kitty] allow the [creation and layout][kitty layout] of multiple terminal panes in a single OS window.
[Terminal multiplexers][tmux] allow the same thing in any terminal emulator that doesn't support it natively.
Using multiple terminal panes managed by either of these systems lets us bring multiple text-based tools to a shared "workbench".

[kitty]: https://sw.kovidgoyal.net/kitty/
[kitty layout]: https://sw.kovidgoyal.net/kitty/overview/#layouts
[tmux]: https://github.com/tmux/tmux/wiki

With this workbench approach, you can have your editor in one pane, a shell for running the compiler in a second, and a script running the server you're developing showing its logs.
Through the [scripting exposed by the terminal][kitty scripting] you can bind a keystroke to [rexecute the last command run in a shell][reterm] without leaving your editor.

[kitty scripting]: https://sw.kovidgoyal.net/kitty/kittens/custom/#using-kittens-to-script-kitty-without-any-terminal-ui
[reterm]: https://github.com/groves/catherd/blob/6c4c98a5289d56f7fad55f060a03929ede35a3b3/reterm.py#L39

Open multiple editors for addresses in a list, move back and forth
Move to editor or shell for project/branch/machine/file/symbol
Opening a new pane in the hub keeps the outpost context of the pane it was openend from e.g. if I open a pane while in a directory in a Docker container through an SSH session, the new pane starts in that directory

## Development is exploration
Search for definitions and usages and files in the current project, both source an docs.

## Lists of lists
Compilation failures, test failures, stack traces, search results, diff chunks are lists of addresses.
They should be navigable and annotatable

## Develop in the execution environment
Text as a medium works at the LCD of environments: local, SSH, Docker, and Docker through SSH are equal
An iPad with an external keyboard can be as effective as a laptop.

## Blit when better
Open a browser or image from Kitty hints and transfer. Docs, PRs, links
Drilling through the terminal stream to the display OS with escapes allows the surrounding chrome to be used: clipboard, file transfer, URL display, bitmap display.

# Why not VS Code
- Ease of hacking
- Own the tools, more skill with the editor or base system compounds over time

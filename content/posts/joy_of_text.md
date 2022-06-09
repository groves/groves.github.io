---
title: "Joy of Text"
date: 2021-10-12T18:03:33-04:00
draft: true
summary: 'Own your tools'
---

## Why
Text goes back to the beginning of computing. While it's not the first way we communicated with computers, it showed up as soon as we had the capabilities. Text efficiently conveys information to people and requires minimal capabilities to produce and display.

That combination, information density and ease of creation, make it an ideal programming substrate. It enables the creation of clear, powerful interfaces while not being so complex as to discourage the programmer from modifying or creating their own interfaces. Using text for display encourages tools that the programmer can truly own, customizing and enhancing them as they learn.

This remixes the Unix philosophy. It keeps the notions of comprehensible programs that work well together to allow for complete user control and comprehension of the environment. It doesn't slavishly keep the notion of text streams as the API between programs. In this philosophy, text is for humans and processes can communicate however's best for them.

## Philosophy

- System is split into an "outpost" where computation happens and text is produced and a "hub" where the text is shown and input is produced to send to the outpost
- Base outpost capabilities are shell, editor, text search, file find, fuzzy search, scrollback
- Base hub capabilities are modern terminal with unicode and programmer fonts, clipboard, browser driving via URL, file transfer, multiple terminal panes
- Base capabilities are testable for upgrades and new outposts
- Text as a medium means the path from hub to outpost doesn't affect its capabilities: local, SSH, Docker, and Docker through SSH are equal
- Able to work immediately in a new outpost. Creating a session sets up all the base capabilities. Even if set up isn't complete, you can invoke commands and they'll block and execute when set up does complete
- Opening a new pane in the hub keeps the outpost context of the pane it was openend from e.g. if I open a pane while in a directory in a Docker container through an SSH session, the new pane starts in that directory
- Own the tools, more skill with the editor or base system compounds over time

- Want to capture some notion of small tools and clear relations making the system debuggable and comprehensible. Is that true? How can we make it inherent in the design of the system? Want to avoid the IDE trap of tools that work differently or only inside of it
	- Maybe the [McIllroy summarization of the Unix philosophy](https://en.wikipedia.org/wiki/Unix_philosophy#Doug_McIlroy_on_Unix_programming)
> This is the Unix philosophy: Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.
		- Though not really as we want text as a human interface, not a program to program interface. Interprocess should use structured data
- Want to bake in a notion of simplicity that text allows on both sides of the system

## Shenandoah Notes
Terminal stream makes an ideal separation between display and computation

Simplicity of text for display removes requirements both on the computation and display sides. The bar is low.

An iPad with an external keyboard can be as effective as a laptop.

Drilling through the terminal stream to the display OS with escapes allows the surrounding chrome to be used: clipboard, file transfer, URL display, bitmap display.

Webapps require so much more of the display in the browser. Their output is much less composable due to the complexity of the app.

Location independent executables let us make the computation environment equally functional with only copy facilities for bootstrap. Determine the architecture with a first command, and then copy over appropriate tools.

---
title: "Why ate?"
date: 2022-10-10T15:23:07-04:00
draft: true
summary: 'Have you heard the good news about hyperlinks?'
---

My name is Charlie Groves and I have a stunning confession to make:
it is 2022 and I have written a [terminal pager].

[terminal pager]: https://en.wikipedia.org/wiki/Terminal_pager

It's not 1984, when the [best known pager][less] was created.
It's 2022.
Why now?

[less]: https://en.wikipedia.org/wiki/Less_(Unix)

In a word: _hyperlinks_.

HTML popularized hyperlinks in the early 1990s.
For the next 25 years, terminal authors slept on linking technology.
Then, in 2017, the authors of Gnome Terminal and iTerm2 added [terminal codes for hyperlinks].
In the intervening years [many][kitty hyperlinks] [other][wezterm hyperlinks] [excellent][windows terminal hyperlinks] [terminals][alacritty hyperlinks] added support. 

[terminal codes for hyperlinks]: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
[kitty hyperlinks]: https://sw.kovidgoyal.net/kitty/glossary/#term-hyperlinks
[wezterm hyperlinks]: https://wezfurlong.org/wezterm/hyperlinks.html
[windows terminal hyperlinks]: https://github.com/microsoft/terminal/pull/7251
[alacritty hyperlinks]: https://github.com/alacritty/alacritty/pull/6139

That critical mass of terminals means more applications can emit links.
Your compiler or test runner or [recursive grep][ripgrep] can now link to a character in a line in a file they think you might find interesting.
I wanted to be able to navigate those links and open them in my editor easily as part of my workflow.

I wrote [ate] to do that.
Before we get into what ate does, let's talk about how terminal links work and make it possible.

[ate]: https://github.com/groves/ate
[ripgrep]: https://github.com/BurntSushi/ripgrep

Terminal Hyperlinks
-------------------
Like setting a color and many other terminal commands, links are started by printing a control code to the terminal stream.
If you emit `\e]8;;file://feh/home/groves\e\\`, text you print after that will link to `/home/groves` on a host named 'feh'.

> Aside: `\e` is the [C escape sequence] for the [escape character] in ASCII.
The escape character starts many terminal control codes.
`\e` is the most common way to see it in when writing out terminal codes.
Escape is the 27th character in ASCII, so it also shows up as 0x1b or 033, which are 27 in hex or octal respectively.

> `\\` is the C escape for `\`. The other characters are literal ASCII characters.

[C escape sequence]: https://en.wikipedia.org/wiki/Escape_sequences_in_C
[escape character]: https://en.wikipedia.org/wiki/Escape_character#ASCII_escape_character

To compare `\e]8;;file://feh/home/groves\e\\` to the equivalent HTML, `<a href="file://feh/home/groves">`:
* `\e` is like `<`, it tells the parser that a tag is coming
* `]8` is like `a`, it indicates what the tag is
* `;;file://feh/home/groves` is like `href=file://feh/home/groves"`, it's the data for that tag
* `\e\\` is like `>`, it says we're out of the tag and back to stuff to show the user

To close a hyperlink in the terminal print `\e]8;;\e\\`.
It's equvalent to `</a>` in HTML.
Text printed after that won't be linked, at least not until another link is started.

To put it all together, run `printf '\e]8;;https://sevorg.org/posts/why_ate/\e\\Why Ate\e]8;;\e\\'` in your terminal.
If your terminal supports links, it will print the text "Why Ate" linking to this page.
Since you're already on this page, I hope that's the most useless terminal hyperlink you encounter.


---
title: "Why ate?"
date: 2022-10-10T15:23:07-04:00
draft: false
summary: 'Have you heard the good news about hyperlinks?'
---

My name is Charlie Groves and I have a stunning confession to make:
I wrote a [terminal pager] in 2022.

[terminal pager]: https://en.wikipedia.org/wiki/Terminal_pager

It's not 1984, when the [best known pager][less] was created.
It's 2022.
Why now?

[less]: https://en.wikipedia.org/wiki/Less_(Unix)

Just one word: _hyperlinks_.

HTML popularized hyperlinks in the early 1990s.
For the next 25 years, terminal authors slept on linking technology.
Then, in 2017, the authors of Gnome Terminal and iTerm2 added [terminal codes for hyperlinks].
In the intervening years [many][kitty hyperlinks] [other][wezterm hyperlinks] [excellent][windows terminal hyperlinks] [terminals][alacritty hyperlinks] added support. 

[terminal codes for hyperlinks]: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
[kitty hyperlinks]: https://sw.kovidgoyal.net/kitty/glossary/#term-hyperlinks
[wezterm hyperlinks]: https://wezfurlong.org/wezterm/hyperlinks.html
[windows terminal hyperlinks]: https://github.com/microsoft/terminal/pull/7251
[alacritty hyperlinks]: https://github.com/alacritty/alacritty/pull/6139

That critical mass of terminals meant more applications can emit links.
Your compiler or test runner or [recursive grep][ripgrep] could link to a character in a line in a file they thought you might find interesting.
I wanted to press one key in my editor to run my compiler or test runner in a separate terminal pane which then navigated to the first error if any.

I wrote [ate] to do that.
Before we get into what ate does, let's talk about how terminal links work and make it possible.

[ate]: https://github.com/groves/ate
[ripgrep]: https://github.com/BurntSushi/ripgrep

Terminal Hyperlinks
===================
Like setting a color and many other terminal commands, links are started by printing an escape sequence to the terminal stream.
Printing `\e]8;;file://feh/home/groves\e\\` starts a link to `/home/groves` on a host named 'feh'.
The terminal will know that text printed after that links there.

> Aside: `\e` is the [C escape sequence] for the [escape character] in ASCII.
The escape character starts terminal escape sequences.
`\e` is a common way to see it in when writing them out.
Escape is the 27th character in ASCII, so you may also see it as 0x1b or 033, which are 27 in hex or octal respectively.

> `\\` is the C escape for `\`. `\e\\` is called "string terminator" in terminals and it ends many escape sequences.

> The other characters are literal ASCII characters.

[C escape sequence]: https://en.wikipedia.org/wiki/Escape_sequences_in_C
[escape character]: https://en.wikipedia.org/wiki/Escape_character#ASCII_escape_character

To compare `\e]8;;file://feh/home/groves\e\\` to the equivalent HTML, `<a href="file://feh/home/groves">`:
* `\e` is like `<`, it tells the parser that a tag is coming
* `]8;` is like `a`, it indicates what the tag is
* `;file://feh/home/groves` is like `href=file://feh/home/groves"`, it's the data for that tag
* `\e\\` is like `>`, it says we're out of the tag and back to stuff to show the user

To close a hyperlink in the terminal print `\e]8;;\e\\`.
It's equvalent to `</a>` in HTML.
Text printed after that won't be linked, at least not until another link is started.

To put it all together, run `printf '\e]8;;https://sevorg.org/posts/why_ate/\e\\Why Ate\e]8;;\e\\'` in your terminal.
If your terminal supports links, it will print the text "Why Ate" linking to this page.
Since you're already on this page, I hope that's the most useless terminal hyperlink you encounter.

Hyperlink Params
----------------
You may have been wondering about the `;` before the `file://` URI in the escape sequence.
Terminal hyperlinks may also include another chunk of data before that `;`: params.
Params are key-value pairs separated by `:`.

`line=12:column=5` would create a key `line` with the value `12` and a key `column` with the value `5` in a hyperlink.
That would look like this in a full hyperlink escape sequence: `\e]8;line=12:column=5;file://feh/home/groves/ate/README.md\e\\`.
An application reading that link could open the file in your editor at the specific line and column given in the params.

Put a Link On It
================
That's all there is to creating links.
As someone authoring a program that runs in the terminal, if you're printing something that relates to a local file, you put a `file://` link on it.
If you're printing something that has a home on the web, you put an `http://` link on it.

Some terminal applications are already doing that:
* [delta] links to files in git diffs and revisions in git log.
* [ls 8.28][ls NEWS] links to files if given a `--hyperlink` flag.
* [gcc 10][gcc 10 static analysis] links to the description of a problem it finds in your code.

[delta]: https://github.com/dandavison/delta
[ls NEWS]: https://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=blob_plain;f=NEWS;hb=HEAD
[gcc 10 static analysis]: https://developers.redhat.com/blog/2020/03/26/static-analysis-in-gcc-10

There's a bit of a bootstrapping problem in getting widespread application support for linking though.
Until enough users want hyperlinks, application authors won't add them.
Until enough applications add hyperlinks, users won't have a reason to use them.
Application authors will likely still add them since it's a cool and useful feature, but it will take a while for it to spread.

Luckily, since [terminal applications are directly manipulable text][joy of text], you don't need to wait for an application to emit links itself.
Kovid Goyal, the author of the [kitty terminal], wanted links to the matches in [ripgrep].
He created a [wrapper around ripgrep that inserts those links][hyperlinked_grep].

[joy of text]: /posts/joy_of_text/
[kitty terminal]: https://sw.kovidgoyal.net/kitty/
[hyperlinked_grep]: https://sw.kovidgoyal.net/kitty/kittens/hyperlinked_grep/

The [link insertion code][ripgrep link insertion] is straightforward:
* take every line of ripgrep's output
* extract which file we're matching
* wrap search results in a link to the matched line in the file
* print ripgrep's original output with those links

[ripgrep link insertion]: https://github.com/kovidgoyal/kitty/blob/48a4edc199a589f80683dfe2a94d5a604247fdb9/kittens/hyperlinked_grep/main.py#L82

With that, you can run `hyperlinked_grep` anywhere you'd run ripgrep,
pass the same flags you'd pass to ripgrep,
get the same displayed output you'd get from ripgrep,
but also get links embedded in that output.

<!---
I'd like to embed the code and walk through it, but it's too off-topic for this post.
```python
# For every line in ripgrep's standard output
for line in p.stdout:
  # Remove existing hyperlinks
  line = osc_pat.sub(b'', line)
  # Create a copy of the line without styling escape codes
  # This is the characters that would be displayed with no formatting
  clean_line = sgr_pat.sub(b'', line).rstrip()
  if not clean_line:
    # If it's a blank line, note that we've left the most recent file
    in_result = b''
    # Write that blank line
    write(b'\n')
  elif in_result:
    # If it's not a blank line and we've seen a 
    m = num_pat.match(clean_line)
    if m is not None:
      is_match_line = m.group(2) == b':'
      if (is_match_line and link_matching_lines) or (not is_match_line and link_context_lines):
        write_hyperlink(write, in_result, line, frag=m.group(1))
        continue
    write(line)
  else:
    if line.strip():
      path = quote_from_bytes(os.path.abspath(clean_line)).encode('utf-8')
      in_result = b'file://' + hostname + path
      if link_file_headers:
        write_hyperlink(write, in_result, line)
        continue
    write(line)
```
-->

I wanted links to compile errors, test failures, and backtraces from [cargo], the Rust build tool.
I wrote a [wrapper around cargo that inserts those links][hyperer] patterned off the one Kovid wrote for ripgrep.

[cargo]: https://doc.rust-lang.org/cargo/
[hyperer]: https://github.com/groves/hyperer

We don't need to track the current file in cargo output, so the [link insertion code][cargo link insertion] is straightforward enough to walk through here:

```python
# Use regular expressions to match certain output from cargo

# Match assertion failures that look eg
# right: `0`', src/main.rs:1012:9
assert_pat = re.compile(br' +(?:left|right):.+ (.+):(\d+):(\d+)')

# Match backtrace lines eg
# at /build/rustc-1.63.0-src/library/core/src/panicking.rs:181:5
btrace_pat = re.compile(br' +at (.+):(\d+):(\d+)')

# Match compile errors eg
#   --> src/main.rs:55:1
num_pat = re.compile(br' +--> (.+):(\d+):(\d+)')

# This gets called for every line cargo prints
# write - a function that writes a line to our output
# raw_line - the input line from cargo with styling included
# clean_line - the text from raw line without styling
def line_handler(write, raw_line, clean_line):
  for pat in [assert_pat, btrace_pat, num_pat]:
    if m := pat.match(clean_line):
      # One of our patterns matched! 
      # Surround raw_line with a link and print it
      write_hyperlink(write, line=raw_line, 
        # Link to the file in the first parentheses in the pattern
        path=m.group(1),
        # Make the URI fragment the line from the second parentheses
        frag=m.group(2))
      return
  # None of the patterns matched. Original line, please drive through
  write(raw_line)
```

[cargo link insertion]: https://github.com/groves/hyperer/blob/dbf4044e6e3670631a940fc518876be2b0ba73d2/hyperer/hcargo.py#L14

All of cargo's output is fed to that line_handler function and you get linkified cargo out the other side.

If you're using kitty, you already have `hyperlinked_grep` installed.
Follow the [setup instructions][hyperlinked_grep] to start using it.

If you're not using kitty and you want `hyperlinked_grep`, or you want my cargo linkifier, you can install [hyperer].
It installs the ripgrep wrapper as `hyperer-rg` and the cargo wrapper as `hyperer-cargo`.

If you want links in the output of another command, hopefully it seems straightforward to write a wrapper now.
hyperer can be a good starting point for writing a wrapper.
Please send PRs to hyperer with any generally useful wrappers.

So, why ate?
============
With an understanding of terminal hyperlinks and how to get them, we can now talk about the motivation for ate.
Like many developers, I love a tight edit-compile-test loop.
An integrated development environment(IDE) "integrates" tools to make that loop tight.
I don't want to give up [the control that an IDE requires][software workshop], so I need a way to integrate arbitrary tools.
ate and terminal hyperlinks do that integration.

[software workshop]: /posts/joy_of_text/#imagining-a-software-development-workshop

{{< rawhtml >}} 

<video width=100% controls>
    <source src="/ate_edit_test_loop.mp4" type="video/mp4">
    Your browser does not support the video tag.  
</video>

{{< /rawhtml >}}

In that video, I:
* make an edit
* hit F4 to rerun my last shell command, `,cargo test`, which is [this script][ATE_OPEN_FIRST] 
* fix the compile error that running `,cargo test` brings me to in my editor
* hit F4 to rerun `,cargo test` and see the compile error fixed

[ATE_OPEN_FIRST]: https://github.com/groves/ate#ate_open_first

That's a tight edit-compile-test loop.

What is ate doing to make that possible?
It looks through the output that hyperer-cargo produces.
If there's a link in the output, ate runs the command in the `ATE_OPENER` environment variable passing it the URI because `ATE_OPEN_FIRST` is set and telling it to open the first link it finds when it runs.

ate also breaks long output into pages like less and other pagers.
It lets you move back and forth between links with `n` and `N`.
It searches in links if you type `/`.

All that's to say that ate doesn't do much.
It's the bridge between commands that produce links and whatever you want to do with those links.
That it's simple is a feature: you can make any terminal program produce links and you can send them to any other program.
ate lets you make that connection however you like, and that's why ate.


# Plumbum: A postmodern line editor

## What?

The goal of this project is to write a line editor in Odin and Lua,
with the goal of having more modern features than your standard ed.
Not to shame ed at all, it's just that he's showing his age a bit.

This document is hopefully eventually going to be an overview and
a little documentation, but for now it's likely just going to be me
thinking out loud (?) about how I want to structure the project.
This is the second attempt at doing something like this, and a
major struggle in the first (which contributed to its abandonment)
was the difficulty in dividing responsibilities between Odin and Lua
code. I would like enough of the functionality to be in Lua that it
can be very hackable and customisable, but to have the most used and
constant functions implemented in Odin, ostensibly for performance
but more realistically just because I want to.

## WHY?!

#### But why the fuck are you writing a line editor in the year 2025?!
Very good question. Mostly because I find the anachronism inherent in creating
a feature-rich, customisable, and extensible line editor pretty funny, and
because I find the whole line editor interesting from a historical perspective.
Also it should be a lot easier to implement than a visual editor, and my ADHD
brain does not want to spend a while fucking around with ncurses or something,
which I would want to do if I were to go down that route.


#### But why is it calle-
Alright, so I feel like I need to apologise for that.
The journey was as follows:

`Line Editor -> LEd -> Lead -> Plumbum`

Yeah it's a bad joke.

## The part where I ramble

Planned structure: Core in Odin, periphery in Lua. Odin should handle a capable
set of primitive operations on the text, and export them to the Lua environment.

It should initialise that environment, and then run the editor loop. I need to
decide whether that loop should be in Odin or in Lua, as that is a significant
architectural difference. However, before that there's some foundations to lay

## The part that's actually a to-do list

- [x] **Implement a buffer type**

    This is gonna be a dynamic array of lines for easy jumping around. One of
    the mistakes I made in the last attempt was using a linked list which while
    interesting in implementation (core:container/intrusive/list is really cool)
    is really messy as a way of handling a buffer. The advantage of the linked
    list approach that drew me to it was in inserting lines in the middle, but
    I feel like in reality that isn't going to be a significant enough issue
    to justify the mess of linked lists.

- [ ] **Define commands for moving around in the buffer**
    
    Create primitives that change the position in the buffer and matching commands
    in the lua interface.

- [ ] **Create an actual command parsing function**

    More formally parse the commands and develop some kind of actual syntax for
    things

- [ ] **Create an RegEx**

    Ok so this one is sorta a stretch goal and definitely some kind of
    masochism, but since watching
    [this Kay Lack video](https://youtu.be/DiXMoBMWMmA?si=8TxdmHF8mIynPWhq)
    I've been itching to give it a proper go, and I'm going to use this
    project as an enabler for my unhealthy desires.

# iictl (Work In Progress)
Controlling ii - Manage server/channel connections.

It is written in **Ada** because I wanted to learn it.
NB! There's a function temporarily written in C.

## Dependencies
Ada (TODO which version?) compiler e.g. gnat.

See above NB.

## Build and install
Build with `make` or `gnatmake iictl.adb`.

Install with `make install`, maybe prepended with `sudo`.

## Usage
Run `iictl` inside `ii`'s `irc` directory.

You don't have to run `ii` if the directory already exist and is populated.

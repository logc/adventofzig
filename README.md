# advent of zig

## Structure

This repository holds solutions to Advent of Code puzzles written in
the programming language Zig.

- `src` holds all source code files. `main.zig` is the main
  program. It uses `aoc.zig` as a library where each daily puzzle has
  a function called as the puzzle itself. The convention is that this
  function returns a `Solutions` struct that holds two numbers: the
  solution to the first part of the puzzle, and the oslution to the
  second part. `main` only needs to invoke the correct function
  following the command line flags set by the user, and then to print
  the solution numbers out.
- `var/data` holds data for puzzle inputs as .txt files. Each daily
  puzzle is in its own subdirectory, under `<year>/<day>`.
- `libs` holds all dependencies of the project, as vendored git
  submodules. This worked better than using the recently released
  package manager.

## Develop

### Build

```shell
$ git submodule init
$ git submodule update
$ zig build
```

Submodules are not needed for every puzzle, but the build will not succeed
without the declared dependencies.

### Test

```shell
$ zig build test
```

The `test` step is added to the normal build on `build.zig` by the
default template.

## License

BSD-3-Clause

See LICENSE file

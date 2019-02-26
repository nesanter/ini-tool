# INI handling tools

*ini-tool* is a small program and library that currently
operates as a proof-of-concept for a flavor of INI
files tentatively called "Simple Safe Settings"
designed for resistance to malformed input at the stream
parser level to facilitate a modular configuration
architecture.

## Tool
When built as an application, the *ini-tool* binary
can be used to perform simple actions on INI files,
including simplification and generating warnings.

## Library
When built as a library or used as a dependency,
`source/ini.d` provides the API for simple file
and string parsing.

## Misc
There's a `misc/sssini.vim` file that can provide
the correct syntax highlighting for this dialect.

---

Copyright © 2019 Noah Santer `<n.ed.santer@gmail.com>`

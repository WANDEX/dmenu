# dmenu
patch set compatible with dmenu-5.0 (2020-09-02)

Extra stuff added to vanilla dmenu:

- reads Xresources (ergo pywal compatible)
- can view color characters like emoji (libxft-bgra is required for this reason)
- `-P` for password mode: hide user input

## Installation

You must have `libxft-bgra` installed until the libxft upstream is fixed.

After making any config changes that you want, but `make`, `sudo make install` it.

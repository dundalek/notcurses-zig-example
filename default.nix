with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "notcurses-env";
  buildInputs = [
    cmake
    git
    zig

    # notcurses dependencies
    libunistring
    ncurses
    qrcodegen
    readline
    zlib
  ];
}

with import <nixpkgs> { };
stdenv.mkDerivation {
  name = "notcurses-env";
  buildInputs = [
    cmake
    git
    zig

    # notcurses dependencies
    pkg-config
    doctest
    libdeflate
    libunistring
    ncurses
    qrcodegen
    readline
    zlib
  ];
}

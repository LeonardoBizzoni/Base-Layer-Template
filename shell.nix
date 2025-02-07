{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    man-pages
    man-pages-posix

    gf
    gcc
    clang
    clang-tools
    universal-ctags

    tree-sitter-grammars.tree-sitter-cpp
    tree-sitter-grammars.tree-sitter-c
  ];

  shellHook = ''
    ${pkgs.onefetch}/bin/onefetch
  '';

  ASAN_OPTIONS = "abort_on_error=1:halt_on_error=1";
  UBSAN_OPTIONS = "abort_on_error=1:halt_on_error=1";
}

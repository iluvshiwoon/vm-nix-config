{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "kershuen";
  # xdg_configHome  = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix {inherit config pkgs lib;};
  shared-files = import ../shared/files.nix {inherit config pkgs;};
in {
  imports = [
    ../shared/neovim
    ../shared/tmux
    ../shared/shell
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files // import ./files.nix {inherit user;};
    stateVersion = "21.05";
  };

  programs = shared-programs;
}

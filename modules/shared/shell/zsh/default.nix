{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "fzf"];
    };
    initExtraFirst = ''
      export PATH=~/.config/emacs/bin:$PATH
      DISABLE_MAGIC_FUNCTIONS=true
      export "MICRO_TRUECOLOR=1"
      eval "$(zoxide init --cmd cd zsh)"
      # eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    initExtra = ''
      flakify () {
        if [ -z "$1" ]; then
          echo "Error: Template name required"
          echo "Usage: nix-init-template <template-name>"
          return 1
        fi

        nix flake init --refresh -t "github:iluvshiwoon/dev-env#$1"
        direnv allow
        echo -e ".direnv\n.envrc" >> ./.gitignore
      }
    '';

    shellAliases = {
      # record = "wf-recorder --audio=alsa_output.pci-0000_08_00.6.analog-stereo.monitor -f $HOME/Videos/$(date +'%Y%m%d%H%M%S_1.mp4')";

      # # Utils
      # c = "clear";
      # # vim = "nvim";
      # cat = "bat";
      # nano = "micro";
      # icat = "kitten icat";
      # dsize = "du -hs";
      # findw = "grep -rl";
      #
      # l = "eza --icons  -a --group-directories-first -1"; # EZA_ICON_SPACING=2
      # ll = "eza --icons  -a --group-directories-first -1 --no-user --long";
      # tree = "eza --icons --tree --group-directories-first";
      #
      # # Nixos
      # cdnix = "cd ~/nixos-config && codium ~/nixos-config";
      # nix-shell = "nix-shell --run zsh";
      # nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      # nix-switchu = "sudo nixos-rebuild switch --upgrade --flake ~/nixos-config#nixos";
      # nix-flake-update = "sudo nix flake update ~/nixos-config#";
      # nix-clean = "sudo nix-collect-garbage && sudo nix-collect-garbage -d && sudo rm /nix/var/nix/gcroots/auto/* && nix-collect-garbage && nix-collect-garbage -d";
      # nix-clean = "sudo nix-collect-garbage -d";
      # nix-cleanold = "sudo nix-collect-garbage --delete-old";
      # nix-cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";

      # Git
      # ga = "git add";
      # gaa = "git add --all";
      # gs = "git status";
      # gb = "git branch";
      # gm = "git merge";
      # gpl = "git pull";
      # gplo = "git pull origin";
      # gps = "git push";
      # gpst = "git push --follow-tags";
      # gpso = "git push origin";
      # gc = "git commit";
      # gcm = "git commit -m";
      # gtag = "git tag -ma";
      # gch = "git checkout";
      # gchb = "git checkout -b";
      # gcoe = "git config user.email";
      # gcon = "git config user.name";
      #
      # g = "lazygit";
      #
      # # python
      # piv = "python -m venv .venv";
      # psv = "source .venv/bin/activate";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}

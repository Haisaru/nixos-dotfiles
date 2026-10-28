{ config, pkgs, lib, ... }:

let
  # Explicit list since vim.desktop/nvim.desktop claim many text/* subtypes
  # directly, which would otherwise win over a text/plain-only default
  textMimeTypes = [
    "text/plain" "text/markdown" "text/x-log" "text/csv" "text/x-makefile"
    "text/x-c" "text/x-csrc" "text/x-chdr" "text/x-c++" "text/x-c++src" "text/x-c++hdr"
    "text/x-java" "text/x-python" "text/x-python3" "text/x-script.python"
    "text/rust" "text/x-go" "text/x-lua" "text/x-tex" "text/x-pascal" "text/x-tcl"
    "text/x-moc" "text/english" "text/x-nix" "text/x-cmake"
    "text/css" "text/javascript" "text/xml"
    "application/x-shellscript" "application/json" "application/xml"
    "application/toml" "application/x-yaml" "application/yaml"
    "application/javascript" "application/x-desktop"
  ];
in
{
  home.username = "jason";
  home.homeDirectory = "/home/jason";
  home.stateVersion = "26.05"; # do not touch

  home.packages = [
  ];

  home.file = {
    ".config/btop/"= { source = ./btop; recursive = true;};
    ".config/cava/"= { source = ./cava; recursive = true;};
    ".config/fastfetch/"= { source = ./fastfetch; recursive = true;};
    ".config/fuzzel/"= { source = ./fuzzel; recursive = true;};
    ".config/hypr/"= { source = ./hypr; recursive = true;};
    ".config/kitty/"= { source = ./kitty; recursive = true;};
    ".config/mako/"= { source = ./mako; recursive = true;};
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    ".config/niri/"= { source = ./niri; recursive = true;};
    ".config/scripts/"= { source = ./scripts; recursive = true;};
    # Single file so Rime can still write its build/ and user dicts beside it
    ".local/share/fcitx5/rime/default.custom.yaml".source = ./rime/default.custom.yaml;
    # Out-of-store so `task context define` / `task config` can write to it
    ".config/task/taskrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/task/taskrc";
    ".config/waybar/"= { source = ./waybar; recursive = true;};
    ".config/wofi/"= { source = ./wofi; recursive = true;};
    ".config/yazi/"= { source = ./yazi; recursive = true;};
    ".zshrc".source = ./.zshrc;
    ".p10k.zsh".source = ./.p10k.zsh;
  };

  # System-wide dark mode: portals, libadwaita, and browsers read color-scheme
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  qt = {
    enable = true;
    # kde platform theme applies the kdeglobals palette below; adwaita ignores it
    platformTheme.name = "kde";
    style = {
      name = "breeze";
      package = pkgs.kdePackages.breeze;
    };
  };

  # KDE apps (Dolphin) take text/view colors from kdeglobals, not the Qt style;
  # without it they fall back to Breeze Light and render dark text on dark bg
  # TerminalApplication: Dolphin runs Terminal=true .desktop files in konsole
  # unless told otherwise, and konsole isn't installed
  xdg.configFile."kdeglobals".text =
    builtins.replaceStrings [ "[General]\n" ] [ "[General]\nTerminalApplication=kitty\nTerminalService=kitty.desktop\n" ]
      (builtins.readFile "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors");

  # Opens text files in nvim inside a fresh kitty window when double-clicked
  xdg.desktopEntries.nvim-kitty = {
    name = "Neovim (kitty)";
    genericName = "Text Editor";
    exec = "kitty -e nvim %F";
    icon = "nvim";
    terminal = false;
    noDisplay = true;
    mimeType = textMimeTypes;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      lib.genAttrs textMimeTypes (_: "nvim-kitty.desktop") // {
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "jason";
      email = "jasonli2442@gmail.com";
    };
  };

  # Regenerated on each switch, so the helper never points at a GC'd gh
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  programs.home-manager.enable = true;
}

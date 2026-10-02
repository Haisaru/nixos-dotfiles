{ config, pkgs, ... }:

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
    # Linked straight to the repo (not the read-only store) so vim.pack can
    # write nvim-pack-lock.json and edits apply without a rebuild
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    ".config/niri/"= { source = ./niri; recursive = true;};
    ".config/scripts/"= { source = ./scripts; recursive = true;};
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
  xdg.configFile."kdeglobals".source =
    "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";

  programs.home-manager.enable = true;
}

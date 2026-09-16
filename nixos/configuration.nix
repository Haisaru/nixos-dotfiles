# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==========================================
  # Display Manager & Desktop (Niri WM)
  # Aesthetic TUI Matrix Login Screen (Ly)
  # ==========================================
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "gameoflife";
      animate = true;
      animation_frame_delay = 30;
      clock = "%a %d %b %H:%M:%S";
      hide_borders = false;
      margin_h = 2;
      margin_v = 1;
      clear_password = true;
      bigclock = false;
    };
  };

  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # ==========================================
  # Power Management & Battery Optimization
  # ==========================================
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # CPU Frequency & Energy Profiles
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Performance Scaling
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 65;

      # Platform Profiles
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Bus & Peripheral Power Saving
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # Audio & Network Power Saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # Disk & Battery Care
      DISK_APM_LEVEL_ON_AC = "254";
      DISK_APM_LEVEL_ON_BAT = "128";
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # ==========================================
  # Networking & Hostname
  # ==========================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;


  # ==========================================
  # Time & Localization
  # ==========================================
  time.timeZone = "America/Edmonton";

  i18n.defaultLocale = "en_US.UTF-8";
  time.hardwareClockInLocalTime = true;

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.libinput.enable = true;

  # ==========================================
  # Audio (PipeWire) & Bluetooth
  # ==========================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ==========================================
  # Nix Settings & Flakes
  # ==========================================
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;


  # ==========================================
  # Shell & User Configuration
  # ==========================================
  programs.zsh.enable = true;

  users.users.jason = {
    isNormalUser = true;
    description = "jason";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
    packages = with pkgs; [
      tree
    ];
  };

  nix.settings.allowed-users = [
    "@wheel"
    "jason"
  ];

  # ==========================================
  # Fonts
  # ==========================================
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  nix.gc = {
    automatic = true;
    options = "--delete older-than 14d";
  };


  # You can use https://search.nixos.org/ to find more packages (and options).
  # ==========================================
  # System Packages
  # ==========================================
  environment.systemPackages = with pkgs; [
    # Terminal & Shell
    bat
    btop
    cava
    eza
    fastfetch
    fd
    fzf
    kitty
    ripgrep
    shfmt
    stylua
    tree-sitter
    unzip
    wget
    yazi
    zoxide
    zsh
    zsh-autocomplete
    zsh-autosuggestions
    zsh-powerlevel10k
    zsh-syntax-highlighting

    # Development Tools & Compilers
    cargo
    claude-code
    claude-monitor
    claude-powerline
    elan
    gcc
    gh
    git
    gnumake
    lazygit
    neovim
    rustc
    texliveFull
    vim

    # Applications & Media
    anki-bin
    firefox
    hunspell
    hunspellDicts.en_CA
    hunspellDicts.en_US
    kdePackages.dolphin
    libreoffice-qt
    librewolf
    mpv
    ncspot
    sioyek
    vesktop
    zathura

    # Wayland & Desktop Utilities
    brightnessctl
    cliphist
    dconf
    fuzzel
    grim
    libnotify
    networkmanagerapplet
    pavucontrol
    playerctl
    satty
    slurp
    swaybg
    swaylock
    trash-cli
    waybar
    wl-clipboard
    wofi
    xdg-utils
    
    # Power Management Tools
    powertop
    tlp
  ];
  system.stateVersion = "26.05"; # Do not touch
}

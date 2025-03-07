# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  #### SYSTEM CONFIGURATION ####

  # System state version - do not change unless you know what you're doing
  system.stateVersion = "24.11";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Garbage collection settings
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  #### BOOT & HARDWARE ####

  # Bootloader configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.kernelModules = [ "amdgpu" ];
  };

  # Hardware configuration
  hardware = {
    # Graphics
    graphics.enable = true;

    # Audio - PipeWire
    pulseaudio.enable = false;
  };

  # Power management
  powerManagement.cpuFreqGovernor = "powersave";

  #### NETWORKING ####

  networking = {
    hostName = "biglabpc";
    networkmanager.enable = true;
    # Uncomment to enable wireless with wpa_supplicant
    # wireless.enable = true;

    # Proxy settings if needed
    # proxy = {
    #   default = "http://user:password@proxy:port/";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    # };
  };

  #### LOCALIZATION ####

  # Time zone
  time.timeZone = "Europe/Zurich";

  # Internationalization
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "fr_CH.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8";
      LC_ALL = "fr_CH.UTF-8";
    };
  };

  # Console keymap
  console.keyMap = "fr_CH";

  #### DESKTOP ENVIRONMENT ####

  # X11 and display server configuration
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];

    # Display manager and desktop environment
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Keyboard layout
    xkb = {
      layout = "ch";
      variant = "fr";
    };
  };

  # GNOME configuration
  services.gnome.core-utilities.enable = true;

  # Enable GNOME extensions through systemPackages
  environment.systemPackages = with pkgs; [
    # GNOME extensions
    gnomeExtensions.pop-shell
    gnomeExtensions.blur-my-shell
    gnomeExtensions.user-themes

    # System utilities
    rustdesk
    microcodeAmd
    gnome-tweaks

    # ZSH plugins
    zsh-syntax-highlighting
    zsh-autosuggestions
  ];

  # Configure dconf settings to enable extensions and set keyboard shortcuts
  programs.dconf.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    # Enable extensions
    [org.gnome.shell]
    enabled-extensions=['pop-shell@system76.com', 'blur-my-shell@aunetx', 'user-theme@gnome-shell-extensions.gcampax.github.com']

    # Configure workspace switching shortcuts
    [org.gnome.desktop.wm.keybindings]
    switch-to-workspace-left=['<Control><Alt>Left']
    switch-to-workspace-right=['<Control><Alt>Right']

    # Configure Pop Shell shortcuts
    [org.gnome.shell.extensions.pop-shell]
    tile-orientation=0
    snap-to-grid=true
    smart-gaps=true

    # Additional GNOME settings to avoid conflicts
    [org.gnome.mutter]
    workspaces-only-on-primary=false
    dynamic-workspaces=false
  '';

  #### SERVICES ####

  # Security services
  security.rtkit.enable = true;

  # System services
  services = {
    # Printing
    printing.enable = true;

    # Network services
    tailscale.enable = true;
    openssh.enable = true;

    # Audio
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # jack.enable = true; # Uncomment for JACK support
    };
  };

  # CPU task affinity service
  systemd.services.high-performance-tasks = {
    description = "Set CPU affinity for high-performance tasks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.util-linux}/bin/taskset -pc 8-15,24-31 1";
    };
  };

  #### VIRTUALIZATION ####

  # VMWare host support
  virtualisation.vmware.host.enable = true;

  #### USER ENVIRONMENT ####

  # Shell configuration - ZSH with Oh-My-Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "fzf" ];
    };

    # Custom aliases and initialization
    interactiveShellInit = ''
      # Check if eza is installed before creating aliases
      if command -v eza > /dev/null; then
        alias ls="eza"
        alias ll="eza -l"
        alias la="eza -a"
        alias lla="eza -la"
        alias lt="eza --tree"
      fi
    '';
  };

  # Browser programs
  programs = {
    firefox.enable = true;
    chromium.enable = true;
  };

  # User accounts
  users.users.nixy = {
    isNormalUser = true;
    description = "nixy";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # UI enhancements
      nerdfonts
      # GNOME extensions moved to system packages

      # Media
      vlc
      mpv

      # Terminal and utilities
      hyfetch
      eza
      fzf
      zsh
      btop
      neovim
      ghostty

      # Applications
      brave
      zed-editor
      proton-pass
    ];
  };

  # Firewall configuration
  # networking.firewall = {
  #   allowedTCPPorts = [ ];
  #   allowedUDPPorts = [ ];
  #   # enable = false; # Uncomment to disable the firewall
  # };
}

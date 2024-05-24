# Edit this configuration file to define what should be installed and working

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
# Merge kernel modules
  boot.initrd.kernelModules = [ "amdgpu" "vfio" "vfio_pci" "vfio_iommu_type1" ];
    # Configure vfio
  boot.kernelModules = [ "kvm" "kvm_amd" ];
  boot.extraModulePackages = [ pkgs.linuxPackages.amdgpu-pro ];

  networking.hostName = "biglab"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "fr_CH.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8";
      LC_ALL = "fr_CH.UTF-8";
    };
  };

  # services
  services = {
    # Enable the X11 windowing system, Gnome and locales with keyboard mapping
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "amdgpu" ];
      layout = "ch";
      xkbVariant = "fr";
    };
    # CUPS to print documents.
    printing.enable = false;
    # Enable audio server
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;
      # Use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # media-session.enable = true;
    };
    # Enable netbird
    netbird = {
      enable = true;
    };
  };

  # Configure console keymap
  console.keyMap = "fr_CH";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "zsh-autosuggestions" "zsh-syntax-highlighting" "vscode" "fzf" ];
    };
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.nixy = {
    isNormalUser = true;
    description = "nixy";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "qemu-libvirtd" "disk" "kvm" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      ungoogled-chromium
      brave
      nerdfonts
      gnomeExtensions.pop-shell
      vlc
      obsidian
      pcloud
      nextcloud-client
      vscode
      hyfetch
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow specific packages.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    microcodeAmd
    neovim
    neofetch
    starship
    alacritty
    gnome.gnome-tweaks
    wget
    curl
    git
    bat
    eza
    mpv
    tmux
    btop
    vlc
    zsh
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
    fuse
    pciutils
    looking-glass-client
    parsec-bin
  ];

# Add a file for looking-glass to use later. This will allow for viewing the guest VM's screen in a
  # performant way.
  systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 nixy qemu-libvirtd -"
  ];

  # Garbage collector to clean up older generations
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # Enable KVM and libvirt
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Enable necessary modules for GPU passthrough
  boot.kernelParams = [ "iommu=1" "amd_iommu=on" ];
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
    options vfio-pci ids=10de:2504,10de:228e
  '';

  # Blacklist the NVIDIA driver on the host
  nixpkgs.config.packageOverrides = pkgs: {
    linux_latest = pkgs.linuxPackages_latest.overrideAttrs (old: rec {
      modDirVersion = "5.15.0";
      extraConfig = old.extraConfig // {
        "DRM_AMDGPU" = "y";
        "DRM_NOUVEAU" = "n";
        "NVIDIA" = "n";
        "NOUVEAU" = "n";
      };
    });
  };

  # This value determines the NixOS release
  system.stateVersion = "23.11";
}

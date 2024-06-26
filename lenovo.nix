# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lenovopc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
       # Load nvidia driver for Xorg and Wayland
       videoDrivers = ["nvidia"];
       enable = true;
       displayManager.gdm.enable = true;
       desktopManager.gnome.enable = true;
       layout = "ch";
       xkbVariant = "fr";
     };
    #  CUPS to print documents.
    printing.enable = false;
    # enable audio server
    pipewire = {
	    enable = true;
	    alsa.enable = true;
	    alsa.support32Bit = true;
	    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  	};
    # enable twingate
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
  };

  programs.fish.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixy = {
    isNormalUser = true;
    description = "nixy";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
    #  thunderbird
    inetutils
    nerdfonts
    gnomeExtensions.pop-shell
    neofetch
    neovim
    obsidian
    git
    btop
    vlc
    vscode
    brave
    nextcloud-client
    ungoogled-chromium
    xclip
    podman
    distrobox
    ];
  };

  # enable podman for distrobox
  virtualisation.podman = {
    enable = true;
    enableNvidia = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # allow specific packages.
  nixpkgs.config.permittedInsecurePackages = [
                "electron-25.9.0"
              ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
   microcodeIntel
   starship
   alacritty
   gnome.gnome-tweaks
   wget
   curl
   git
   bat
   ripgrep
   eza
   mpv
   tmux
   netbird
   netbird-ui
   gcc
   gnumake
   conda
];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # garbage collector to clean up older generations
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 15d";
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

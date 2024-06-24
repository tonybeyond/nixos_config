{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules and parameters
  boot.initrd.kernelModules = [ "amdgpu" "vfio" "vfio_pci" "vfio_iommu_type1" ];
  boot.kernelModules = [ "kvm" "kvm_amd" ];
  boot.extraModulePackages = [ pkgs.linuxPackages.amdgpu-pro ];
  boot.kernelParams = [ 
    "iommu=1" 
    "amd_iommu=on"
    "default_hugepagesz=1G" 
    "hugepagesz=1G" 
    "hugepages=16"  # Reserving 16GB for hugepages, adjust as needed
    "isolcpus=8-15,24-31"  # Isolating 8 cores (16 threads) for VM use
  ];
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
    options vfio-pci ids=10de:2503,10de:228e  # RTX 3060 IDs, verify these
  '';

  # CPU governor and I/O scheduler
  powerManagement.cpuFreqGovernor = "performance";
  boot.kernelParams = boot.kernelParams ++ [ "elevator=none" ];

  # Networking
  networking.hostName = "biglab";
  networking.networkmanager.enable = true;

  # Time zone and internationalization (unchanged)
  # ... (keep your existing time and i18n settings)

  # Services (including X11, audio, and netbird)
  services = {
    # ... (keep your existing service configurations)
    
    # Add CPU scheduler for isolated cores
    system76-scheduler = {
      enable = true;
      settings.cfsProfiles.performance = "8-15,24-31";
    };
  };

  # Console keymap (unchanged)
  console.keyMap = "fr_CH";

  # Sound and OpenGL (unchanged)
  # ... (keep your existing sound and OpenGL configurations)

  # User configuration (unchanged)
  # ... (keep your existing user configurations)

  # Packages (unchanged)
  # ... (keep your existing package configurations)

  # Looking Glass configuration (unchanged)
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 nixy qemu-libvirtd -"
  ];

  # Garbage collector (unchanged)
  # ... (keep your existing GC configuration)

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Hugepages configuration
  boot.kernel.sysctl = {
    "vm.nr_hugepages" = 16;
    "vm.hugetlb_shm_group" = 78;  # Verify this matches your kvm group ID
  };

  # Adjust max locked memory for KVM group
  security.pam.loginLimits = [
    {
      domain = "@kvm";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];

  # GPU passthrough configuration
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

  # System version
  system.stateVersion = "24.05";
}

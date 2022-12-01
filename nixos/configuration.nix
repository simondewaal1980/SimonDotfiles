# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    <home-manager/nixos>
    ];

    nixpkgs.config.allowUnfree = true;


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.enableContainers = false;

   networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
   networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

zramSwap = {
    enable = true;
    algorithm = "zstd";
  };


 #polkit
 security.polkit.enable =true;
 

 #autoupdater
 system.autoUpgrade.enable = true;
system.autoUpgrade.allowReboot = false;
#Auto garbagecollector
  nix.gc = {
        automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
#auto optimise Nix store
 nix.settings.auto-optimise-store = true;
  
#NIX command
 nix.settings.experimental-features = [ "nix-command" ];



  # Set your time zone.
   time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "nl_NL.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
  #  useXkbConfig = true; # use xkbOptions in tty.
   };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the Desktop Environment.
services.xserver.displayManager.lightdm.enable = true;
services.xserver.displayManager.lightdm.greeters.slick.enable =true;

services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
services.xserver.desktopManager.cinnamon.enable = true;
services.xserver.desktopManager.kodi.enable = true;

environment.pathsToLink = [ "/libexec" ];
services.xserver.windowManager.i3.package = pkgs.i3-gaps;
services.xserver.windowManager.i3.enable =true;
services.xserver.windowManager.i3.extraPackages = with pkgs; [rofi i3lock i3status];

  # Configure keymap in X11
 #  services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
   #  "eurosign:e";
    # "caps:escape"; # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

#pipewire sound
hardware.pulseaudio.enable = false;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
};
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.simon = {
     isNormalUser = true;
     extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.

       packages = with pkgs; [
       google-chrome
       libreoffice-fresh
       spotify
       gettext
       neofetch
        
      ];
  };

  #VM test user
  
  users.users.simon.initialPassword = "test";
#Vim config
  environment.etc."vimrc".text = ''
    syntax on
    set number
    colorscheme elflord
  '';
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
 
    any-nix-shell 
    vim_configurable  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     virt-manager
     distrobox
     git 

     #Polkit
   pkgs.lxqt.lxqt-policykit
      #diverse pakketten
      obs-studio
      pkgs.vlc
      pkgs.teams
      pkgs.hunspellDicts.nl_nl
      gnome-console
      ncspot
      xorg.xhost
      gparted 
      vscode
 #Windowmanager benodigdheden
      pulseaudio
      picom
      polybarFull
      feh
      conky
      dmenu
      rofi
      kitty
      autotiling
      playerctl
      pavucontrol
      dunst
      variety
      pkgs.github-desktop
      xdotool

      pkgs.obs-studio-plugins.obs-backgroundremoval
     # obs-studio
   #Kodi
      (pkgs.kodi.withPackages (p: with p; [
      inputstream-adaptive
      netflix
      vfs-sftp
    
    ]))
    
    meld
    synthv1
  ];

#fonts
  fonts.fonts = [ pkgs.font-awesome ];

 #Some programs need SUID wrappers, can be configured further or are
  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;
 
  #Program enablers
  #Fish
 users.defaultUserShell = pkgs.bash;
  
   programs.bash.interactiveShellInit = "fish";
  programs.fish.enable =true;
 programs.fish.shellInit = "neofetch";
 programs.fish.promptInit = ''
 any-nix-shell fish --info-right | source
  '';


  #Steam
  programs.steam.enable =true;


  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

services.openssh.forwardX11 =true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
#Shell aliases
environment.shellAliases ={
  #ls = "ls -la";
  sysupgr = "sudo nixos-rebuild boot --upgrade";
  sysswitch = "sudo nixos-rebuild switch --upgrade";  
  sysconfig = "sudo vim /etc/nixos/configuration.nix";
  sysclean  = "sudo nix-collect-garbage -d";
  listgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

};

#homemanager

home-manager.users.simon = { pkgs, ... }: {
 home.stateVersion = "22.11";

 home.packages = [ 
 pkgs.helix
];
programs.exa.enable = true;


};


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  # This value determines the NixOS release from which the default



  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?

}


{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
  };
  outputs =
    { self, ... }@inputs:
    let
      targets = [
        #"x86_64-linux"
        "i686-linux"
        #"aarch64-linux"
        "armv7l-linux"
        "armv6l-linux"
      ];
      packages = [
        #a
        "ansible"
        "apacheHttpd"
        "apt"
        #b
        "bash"
        "binutils"
        "blender"
        "boost"
        "busybox"
        #c
        "chromium"
        "claws-mail"
        "clippy"
        "cmake"
        "coreutils"
        "coreutils-full"
        "cppcheck"
        "cups"
        "curl"
        #d
        "darktable"
        "djvulibre"
        "dnf4"
        "dnf5"
        "dnsmasq"
        "docker"
        "dosbox"
        "dovecot"
        "doxygen"
        #e
        "emacs"
        "evince"
        #f
        "fastfetch"
        "ffmpeg"
        "ffmpeg-full"
        "firefox"
        "firefox-esr"
        "fish"
        "flatpak"
        "flatpak-builder"
        "freecad"
        "freeciv"
        #g
        "gcc"
        "gdb"
        "geeqie"
        "gimp"
        "git"
        "gnupg"
        "go"
        "godot"
        "grafana"
        "graphviz"
        "grub2"
        "gtk4"
        #h
        "haproxy"
        "home-assistant"
        "hydra"
        "hyprland"
        #i
        "i2p"
        "i2pd"
        "i3"
        "imagemagick"
        "inkscape"
        #j
        "jellyfin"
        "jq"
        #k
        "krita"
        "kubernetes"
        #l
        "lame"
        "less"
        "libreoffice"
        "linux"
        "llvm"
        #m
        "mariadb-server"
        "maxima"
        "mc"
        "mesa"
        "meson"
        "mplayer"
        "mutt"
        "mysql84"
        #n
        "nano"
        "neofetch"
        "neovim"
        "networkmanager"
        "nginx"
        "nix"
        "nmap"
        "nodejs"
        #o
        "octave"
        "okular"
        "openssh"
        "openssl"
        "openttd"
        "openvpn"
        #p
        "p7zip"
        "pacman"
        "pidgin"
        "pipes"
        "pihole"
        "podman"
        "postfix"
        "postgresql"
        "privoxy"
        "prometheus"
        "python"
        "python3"
        #q
        "qemu"
        "qt5Full"
        #r
        "rdesktop"
        "redis"
        "rsync"
        "rtorrent"
        "rustc"
        #s
        "samba"
        "sane-backends"
        "scribus"
        "scummvm"
        "smartmontools"
        "sqlite"
        "squid"
        "stdenv"
        "stellarium"
        "sudo"
        "systemd"
        #t
        "thunderbird"
        "tmux"
        "tor"
        "toybox"
        "transmission"
        # u
        "unbound"
        #v
        "valgrind"
        "vim"
        "virtualbox"
        "vlc"
        #w
        "wayland"
        "wesnoth"
        "wget"
        "which"
        "wine"
        "wireshark"
        "xorg-server"
        "xterm"
        "yggdrasil"
        "yt-dlp"
        #z
        "zeromq"
        "zsh"
      ];
      hosts = builtins.map (host: (builtins.replaceStrings [ ".nix" ] [ "" ] host)) (
        builtins.attrNames (builtins.readDir (./hosts))
      );
      pkgs = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
          };
        }) targets
      );
      pkgs-broken = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowBroken = true;
          };
        }) targets
      );
      pkgs-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowUnsupportedSystem = true;
          };
        }) targets
      );
      pkgs-broken-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
          };
        }) targets
      );
    in
    {
      packages = builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs.${target}.${package};
            }) packages
          );
        }) targets
      );

      packages-broken = builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs-broken.${target}.${package};
            }) packages
          );
        }) targets
      );

      packages-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs-unsupported.${target}.${package};
            }) packages
          );
        }) targets
      );

      packages-broken-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs-broken-unsupported.${target}.${package};
            }) packages
          );
        }) targets
      );

      nixosConfigurations =
        (builtins.listToAttrs (
          builtins.map (target: {
            name = target;
            value = inputs.nixpkgs-unstable.lib.nixosSystem {
              system = "${target}";
              modules = [
                ./host.nix
              ];
            };
          }) targets
        ))
        // (builtins.listToAttrs (
          builtins.concatMap (
            target:
            (builtins.map (host: {
              name = "${target}-${host}";
              value = inputs.nixpkgs-unstable.lib.nixosSystem {
                system = "${target}";
                modules = [
                  (./hosts + "/${host}.nix")
                ];
              };
            }) hosts)
          ) targets
        ));

      hydraJobs = {
        inherit (self) packages;
        inherit (self) packages-broken;
        inherit (self) packages-unsupported;
        inherit (self) packages-broken-unsupported;
        nixosConfigurations =
          builtins.listToAttrs (
            map (target: {
              name = target;
              value = self.nixosConfigurations.${target}.config.system.build.toplevel;
            }) targets
          )
          // (builtins.listToAttrs (
            builtins.concatMap (
              target:
              (builtins.map (host: {
                name = "${target}-${host}";
                value = self.nixosConfigurations."${target}-${host}".config.system.build.toplevel;
              }) hosts)
            ) targets
          ));
      };
    };
}

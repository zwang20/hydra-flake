{
    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
        nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";
        nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
        nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    };
    outputs = { self, ... }@inputs:
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
        #b
        "bash"
        "binutils"
        "blender"
        "boost"
        #c
        "chromium"
        "claws-mail"
        "cmake"
        "coreutils"
        "cppcheck"
        "cups"
        "curl"
        #d
        "darktable"
        "djvulibre"
        "dnsmasq"
        "dosbox"
        "dovecot"
        "doxygen"
        #e
        "emacs"
        "evince"
        #f
        "fastfetch"
        "ffmpeg"
        "firefox"
        "fish"
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
        "pidgin"
        "pip"
        "pihole"
        "postfix"
        "postgresql"
        "privoxy"
        "prometheus"
        "python"
        #q
        "qemu"
        "qt-full"
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
        #t
        "thunderbird"
        "tmux"
        "tor"
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
        "wine"
        "wireshark"
        "xorg-server"
        "xterm"
        "yt-dlp"
        #z
        "zeromq"
        "zsh"
    ];
    pkgs = builtins.listToAttrs (map (target: {
        name = target;
        value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
        };
    }) targets);
    in
    {
        packages = builtins.listToAttrs (map (target: {
            name = target;
            value = {
                default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
            } // builtins.listToAttrs (map (package: {
                name = package;
                value = pkgs.${target}.${package};
            }) packages);
        }) targets);

        nixosConfigurations = builtins.listToAttrs (map (target: {
            name = target;
            value = inputs.nixpkgs-unstable.lib.nixosSystem {
                system = "${target}";
                modules = [
                    ./host.nix
                ];
            };
        }) targets);

        hydraJobs = {
            inherit (self) packages;
            nixosConfigurations = builtins.listToAttrs (map (target: {
                name = target;
                value = self.nixosConfigurations.${target}.config.system.build.toplevel;
            }) targets);
        };
    };
}

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
        "apache-httpd"
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
        "graphvis"
        "grub"
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
        "mysql"
        #n
        "nix"
        #p
        "pihole"
        "postfix"
        "postgresql"
        "prometheus"
        #s
        "samba"
        "stdenv"
        #t
        "tor"
        # u
        "unbound"
    ];
    pkgs = builtins.listToAttrs (map (target: {
        name = target;
        value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowBroken = true;
            config.allowUnsupportedSystems = true;
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

        hydraJobs = {
            inherit (self) packages;
        };
    };
}

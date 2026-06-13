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
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "armv7l-linux"
        "armv6l-linux"
    ];
    packages = [
        "stdenv"
        "fastfetch"
        "firefox"
    ];
    pkgs = builtins.listToAttrs (map (target: {
        name = target;
        value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.problems.handlers.defaut.broken = "warn";
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

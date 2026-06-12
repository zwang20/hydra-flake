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
    in
    {
        packages = builtins.listToAttrs (map (target: {
            name = target;
            value = with inputs.nixpkgs-unstable.legacyPackages.${target}; {
                default = hello;
                fastfetch = fastfetch;
            };
        }) targets);

        hydraJobs = {
            inherit (self) packages;
        };
    };
}

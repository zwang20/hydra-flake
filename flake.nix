{
    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
        nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";
        nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
        nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    };
    outputs = { self, ... }@inputs:
    {
        packages = {
            x86_64-linux = {
                default = inputs.nixpkgs-unstable.legacyPackages.x86_64.hello;
            };
            i686-linux = {
                default = inputs.nixpkgs-unstable.legacyPackages.i686-linux.hello;
            };
            aarch64-linux = {
                default = inputs.nixpkgs-unstable.legacyPackages.aarch64-linux.hello;
            };
            armv7l-linux = {
                default = inputs.nixpkgs-unstable.legacyPackages.armv7l-linux.hello;
            };
            armv6l-linux = {
                default = inputs.nixpkgs-unstable.legacyPackages.armv6l-linux.hello;
            };
        };

        hydraJobs = {
            inherit (self) packages;
        };
    };
}

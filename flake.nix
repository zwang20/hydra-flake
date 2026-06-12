{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    outputs = { self, nixpkgs, ... }: {
        packages = {
            x86_64-linux = {
                default = nixpkgs.legacyPackages.x86_64.hello;
            };
            i686-linux = {
                default = nixpkgs.legacyPackages.i686-linux.hello;
            };
            aarch64-linux = {
                default = nixpkgs.legacyPackages.aarch64-linux.hello;
            };
            armv7l-linux = {
                default = nixpkgs.legacyPackages.armv7l-linux.hello;
            };
        };

        hydraJobs = {
            inherit (self) packages;
        };
    };
}

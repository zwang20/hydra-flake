{
    nixpkgs,
    system,
}:
let
    packages = import ./config/packages.nix;
    pkgs = import nixpkgs {
        inherit system;
        config.allowBroken = true;
        config.allowUnsupportedSystem = true;
    };
in
{
    jobs = builtins.listToAttrs (
        map (package: {
            name = package;
            value = pkgs.${package};
        }) packages
    );
}


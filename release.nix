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
    lib = pkgs.lib;
in
{
    ${system} = builtins.listToAttrs (
        map (package: {
            name = package;
            value = lib.attrByPath (lib.splitString "." package) null pkgs;
        }) packages
    );
}


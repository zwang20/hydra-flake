{
    nixpkgs,
    system,
}:
let
    pkgs = import nixpkgs {
        inherit system;
        config.allowBroken = true;
        config.allowUnsupportedSystem = true;
    };
in
{
    jobs = {
        hello = pkgs.hello;
    };
}


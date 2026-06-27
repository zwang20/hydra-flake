{
    nixpkgs,
    system,
}:
let
    pkgs = nixpkgs {
        system = system;
        config.allowBroken = true;
        config.allowUnsupportedSystem = true;
    };
in
{
    jobs = {
        hello = pkgs.hello;
    };
}


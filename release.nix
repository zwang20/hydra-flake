{
    nixpkgs,
    system,
}:

{
    jobs = {
        hello = nixpkgs.legacyPackages.system.hello;
    };
}


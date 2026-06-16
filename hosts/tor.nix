{ ... }:
{
    imports = [
        ../modules/default.nix
    ];
    services.tor.enable = true;
}

{ ... }:
{
    imports = [
        ../modules/default.nix
    ];
    services.desktopManager.lomiri.enable = true;
}

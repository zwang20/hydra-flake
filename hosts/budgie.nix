{ ... }:
{
    imports = [
        ../modules/default.nix
    ];
    nixpkgs.config.allowUnsupportedSystem = true;
    services.desktopManager.budgie.enable = true;
}

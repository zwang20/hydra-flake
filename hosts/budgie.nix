{ ... }:
{
  imports = [
    ../modules/default.nix
  ];
  services.desktopManager.budgie.enable = true;
}

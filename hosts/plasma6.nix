{ ... }:
{
  imports = [
    ../modules/default.nix
  ];
  services.desktopManager.plasma6.enable = true;
}

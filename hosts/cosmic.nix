{ ... }:
{
  imports = [
    ../modules/default.nix
  ];
  services.desktopManager.cosmic.enable = true;
}

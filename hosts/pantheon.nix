{ ... }:
{
  imports = [
    ../modules/default.nix
  ];
  services.desktopManager.pantheon.enable = true;
}

{ ... }:
{
  imports = [
    ../modules/default.nix
  ];
  services.desktopManager.gnome.enable = true;
}

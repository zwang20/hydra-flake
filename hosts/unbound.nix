{ ... }:
{
  imports = [
    ../modules/default.nix
  ];
  services.unbound.enable = true;
}

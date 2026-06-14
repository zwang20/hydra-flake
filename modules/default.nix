{ ... }:
{
    fileSystems = {
        "/" = {
            device = "/dev/sda2";
            fsType = "ext4";
        };

        "/boot" = {
            device = "/dev/sda1";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
    };
    nixpkgs.config.allowUnsupportedSystem = true;
}

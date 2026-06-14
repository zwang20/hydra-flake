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
    nixpkgs.config = {
        allowBroken = true;
        allowUnsupportedSystem = true;
    };
    boot.loader.grub.devices = [ "/dev/sda" ];
}

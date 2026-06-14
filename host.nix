{ ... }:
{
    nixpkgs.config.allowUnsupportedSystem = true;
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
    boot.loader.systemd-boot.enable = true;
    boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" ];
    services = {
        openssh.enable = true;
    };
}

{ ... }:
{
    imports = [
        ./modules/default.nix
    ];
    boot.loader.systemd-boot.enable = true;
    boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" ];
    services = {
        openssh.enable = true;
    };
}

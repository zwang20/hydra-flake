{ ... }:
{
    boot.loader.systemd-boot.enable = true;
    boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" ];
    services = {
        openssh.enable = true;
        qemuGuest.enable = true;
    };
}

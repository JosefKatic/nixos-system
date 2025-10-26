{
  device.platform = "aarch64-linux";
  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "9p"
    "9pnet_virtio"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
    "virtio_gpu"
  ];
  device.type = "server";
  device.virtualized = true;
  device.boot.quietboot.enable = true;
  device.boot.uefi.enable = true;
  device.boot.uefi.secureboot = false;
  device.home.users = [ "joka" ];
  device.core.storage.enablePersistence = true;
  device.core.storage.otherDrives = [ ];
  device.core.storage.swapFile.enable = true;
  device.core.storage.swapFile.path = "/swap/swapfile";
  device.core.storage.swapFile.size = 16;
  device.core.storage.systemDrive.encrypted.enable = false;
  device.core.storage.systemDrive.encrypted.path = "";
  device.core.storage.systemDrive.name = "system";
  device.core.storage.systemDrive.path = "/dev/disk/by-label/system";
}

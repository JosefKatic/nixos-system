{
  device.platform = "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  device.type = "server";
  device.virtualized = true;
  device.boot.quietboot.enable = true;
  device.boot.uefi.enable = false;
  device.boot.uefi.secureboot = false;
  device.core.storage.enablePersistence = true;
  device.core.storage.otherDrives = [ ];
  device.core.storage.swapFile.enable = true;
  device.core.storage.swapFile.path = "/swap/swapfile";
  device.core.storage.swapFile.size = 8;
  device.core.storage.systemDrive.encrypted.enable = false;
  device.core.storage.systemDrive.encrypted.path = "";
  device.core.storage.systemDrive.name = "system";
  device.core.storage.systemDrive.path = "/dev/disk/by-label/system";
  device.hardware.bluetooth.enable = false;
  device.hardware.bluetooth.enableManager = false;
  device.hardware.cpu.amd.enable = true;
  device.hardware.cpu.intel.enable = false;
  device.hardware.disks.hdd.enable = false;
  device.hardware.disks.ssd.enable = true;
  device.hardware.gpu.amd.enable = false;
  device.hardware.gpu.intel.enable = false;
  device.hardware.gpu.nvidia.enable = false;
  device.hardware.misc.trezor.enable = false;
  device.hardware.misc.xbox.enable = false;
  device.hardware.misc.yubikey.enable = false;
  device.home.users = [ "joka" ];
}

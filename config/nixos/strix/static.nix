{
  device.platform = "x86_64-linux";
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"];
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  device.type = "server";
  device.virtualized = true;
  device.boot.quietboot.enable = true;
  device.boot.uefi.enable = false;
  device.boot.uefi.secureboot = false;
  device.core.network.static.enable = true;
  device.core.network.static.interfaces."ens3".ipv4.addresses = [
    {
      address = "193.41.237.192";
      prefixLength = 24;
    }
  ];
  device.core.network.static.defaultGateway.address = "193.41.237.1";
  device.core.network.static.defaultGateway.interface = "ens3";
  device.core.network.static.nameservers = ["100.64.0.4" "1.1.1.1"];
  device.core.storage.enablePersistence = true;
  device.core.storage.otherDrives = [];
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
  device.home.users = ["joka"];
}

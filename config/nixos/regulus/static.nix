{
  device.platform = "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "sr_mod"
    "uhci_hcd"
    "virtio_blk"
    "virtio_pci"
  ];
  device.type = "server";
  device.virtualized = false;
  device.boot.quietboot.enable = true;
  device.boot.uefi.enable = true;
  device.boot.uefi.secureboot = true;
  device.core.network.static.enable = true;
  device.core.network.static.interfaces."eno2".ipv4.addresses = [
    {
      address = "10.34.70.20";
      prefixLength = 23;
    }
  ];
  device.core.network.static.defaultGateway.address = "10.34.70.61";
  device.core.network.static.defaultGateway.interface = "eno2";
  device.core.network.static.nameservers = [
    "127.0.0.1"
    "10.34.70.20"
    "10.34.70.61"
    "100.100.100.100"
  ];
  device.core.network.static.search = [
    "clients.joka00.dev"
    "internal.joka00.dev"
    "oraclevcn.com"
  ];
  device.core.storage.enablePersistence = true;
  device.core.storage.otherDrives = [ ];
  device.core.storage.swapFile.enable = true;
  device.core.storage.swapFile.path = "/swap/swapfile";
  device.core.storage.swapFile.size = 8;
  device.core.storage.systemDrive.encrypted.enable = true;
  device.core.storage.systemDrive.encrypted.path = "/dev/disk/by-partlabel/cryptsystem";
  device.core.storage.systemDrive.name = "system";
  device.core.storage.systemDrive.path = "/dev/disk/by-label/system";
  device.hardware.bluetooth.enable = true;
  device.hardware.bluetooth.enableManager = false;
  device.hardware.cpu.amd.enable = false;
  device.hardware.cpu.intel.enable = true;
  device.hardware.disks.hdd.enable = false;
  device.hardware.disks.ssd.enable = true;
  device.hardware.gpu.amd.enable = false;
  device.hardware.gpu.intel.enable = true;
  device.hardware.gpu.nvidia.enable = false;
  device.hardware.misc.trezor.enable = false;
  device.hardware.misc.xbox.enable = false;
  device.hardware.misc.yubikey.enable = false;
  device.home.users = [ "joka" ];
}

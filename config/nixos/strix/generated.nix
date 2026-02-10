{
  device.build = "FzmK7W5o44OWWB0mBXr2xjSUn+4Q=";
  device.core.disableDefaults = true;
  device.core.locale.defaultLocale = "en_US.UTF-8";
  device.core.locale.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "cs_CZ.UTF-8/UTF-8"
  ];
  device.core.locale.timeZone = "Europe/Prague";
  device.core.network.domain = "clients.joka00.dev";
  device.core.network.services.enableAvahi = false;
  device.core.network.services.enableNetworkManager = false;
  device.core.network.services.enableResolved = false;
  device.core.securityRules.enable = true;
  device.core.shells.fish.enable = true;
  device.core.shells.zsh.enable = false;
  device.desktop.gamemode.enable = false;
  device.desktop.wayland.desktopManager.gnome.enable = false;
  device.desktop.wayland.desktopManager.plasma6.enable = false;
  device.desktop.wayland.displayManager.gdm.enable = false;
  device.desktop.wayland.windowManager.hyprland.enable = false;
  device.desktop.wayland.windowManager.sway.enable = false;
  device.server.cache.enable = true;
  device.server.databases.mysql.enable = true;
  device.server.databases.postgresql.enable = true;
  device.server.hydra.enable = false;
  device.server.minecraft.enable = true;
  device.server.proxy.traefik.enable = true;
  device.server.teamspeak.enable = true;
  device.server.services.fail2ban.enable = true;
  device.server.services.headscale.enable = false;
  device.server.services.hosting.website.enable = false;
  device.utils.kdeconnect.enable = false;
  device.utils.virtualisation.docker.enable = false;
  device.utils.virtualisation.libvirtd.enable = false;
  device.utils.virtualisation.podman.enable = true;
}

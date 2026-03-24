{
  services = {
    logind.settings.Login = {
      HandlePowerKey = "suspend";
    };

    # battery info
    upower.enable = true;
    # power profiles
    power-profiles-daemon.enable = true;
  };
}

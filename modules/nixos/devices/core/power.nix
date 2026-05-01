{
  services = {
    logind.settings.Login = {
      HandlePowerKey = "suspend";
    };

    # battery info
    upower.enable = true;
  };
}

{ inputs, ... }:
{
  company = {
    autoUpgrade =
      let
        enableIfClean = inputs.self ? rev;
      in
      {
        dates = "*:0/10";
        oldFlakeRef = "self";
        system.enable = enableIfClean;
        user.enable = enableIfClean;
      };
  };
}

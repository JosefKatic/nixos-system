{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.programs.editors.vscode;
  caelestiaShell = config.user.desktop.wayland.shell.enable;

  caelestiaVsix = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/caelestia-dots/caelestia/main/vscode/caelestia-vscode-integration/caelestia-vscode-integration-1.2.0.vsix";
    sha256 = "1yvrm5qx91fvip34i2d135yk178vfahyhsn6pcfjdb65wsh79vc8";
  };

  caelestiaVscodeIntegration = pkgs.callPackage ./caelestia-vscode-integration.nix {
    vsix = caelestiaVsix;
  };
  caelestiaVscodeExtId = "soramanew.caelestia-vscode-integration-${caelestiaVscodeIntegration.version}";
in
{
  options = {
    user.desktop.programs.editors = {
      vscode = {
        enable = lib.mkEnableOption "Enable VSCode";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.vscode;
          description = "Enable VS Code";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.vscode = {
          enable = cfg.enable;
          package = cfg.package;
          profiles.default = {
            enableExtensionUpdateCheck = true;
          };
          mutableExtensionsDir = true;
        };
        home.packages = [
          pkgs.code-cursor
          pkgs.lmstudio
          pkgs.cursor-cli
          pkgs.inputs.llm-agents.claude-code
          pkgs.inputs.codebase-mcp.default
          pkgs.inputs.llm-agents.spec-kit
          pkgs.inputs.llm-agents.cursor-agent
          pkgs.inputs.llm-agents.kilocode-cli
        ];
      }

      (lib.mkIf caelestiaShell {
        # Caelestia vscode/flags.conf — Chromium-style flags read by VS Code / Cursor on Linux (User/flags.conf).
        xdg.configFile = {
          "Code/User/flags.conf".source = ./flags.conf;
          "Cursor/User/flags.conf".source = ./flags.conf;
        };

        # Register the official VSIX with each editor so they use their real extensions roots (plain cp under
        # ~/.vscode/extensions is easy to miss vs what the Microsoft build actually loads).
        home.activation.caelestiaVscodeIntegrationInstall = lib.hm.dag.entryAfter [ "vscodeProfiles" ] ''
          set -eu
          _vsix=${lib.escapeShellArg caelestiaVsix}
          _unpack=${lib.escapeShellArg "${caelestiaVscodeIntegration}"}
          _extid=${lib.escapeShellArg caelestiaVscodeExtId}
          _code=${lib.escapeShellArg (lib.getExe cfg.package)}
          _cursor=${lib.escapeShellArg (lib.getExe pkgs.code-cursor)}
          _vsdir="${config.home.homeDirectory}/${config.programs.vscode.dataFolderName}/extensions"
          _cudir="${config.home.homeDirectory}/.cursor/extensions"

          _install_or_copy() {
            _bin="''$1"
            _extroot="''$2"
            if [ ! -x "$_bin" ]; then
              return 0
            fi
            "$_bin" --uninstall-extension soramanew.caelestia-vscode-integration 2>/dev/null || true
            if "$_bin" --install-extension "$_vsix" 2>/dev/null; then
              return 0
            fi
            install -d "$_extroot"
            _dst="$_extroot/$_extid"
            rm -rf "$_dst"
            cp -a "$_unpack/." "$_dst"
            chmod -R u+w "$_dst"
          }

          _install_or_copy "$_code" "$_vsdir"
          _install_or_copy "$_cursor" "$_cudir"
        '';
      })
    ]
  );
}

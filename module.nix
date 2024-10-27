flake:
{
  pkgs,
  config,
  lib,
  options,
  ...
}:
let
  service_name = "verify-time-machine";
  cfg = config.services.${service_name};
in
{
  options.services.${service_name} =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption service_name;
      schedule = mkOption {
        type =
          with types;
          submodule {
            options = {
              Hour = mkOption {
                type = ints.between 0 23;
                description = "Hour of day to run";
                default = 4;
              };
              Minute = mkOption {
                type = ints.between 0 59;
                description = "Minute of the hour to run";
                default = 5;
              };
            };
          };
        default = { };
      };
      stdout = mkOption {
        type = types.str;
        default = null;
      };
      stderr = mkOption {
        type = types.str;
        default = null;
      };
    };

  config =
    let
      inherit (lib) mkIf optionalAttrs;
    in
    mkIf cfg.enable (
      optionalAttrs (options ? launchd) {
        launchd.agents.${service_name} = {
          enable = true;
          config = {
            Label = "com.n8henrie.${service_name}";
            ProgramArguments = [ flake.apps.${pkgs.system}.default.program ];
            StartCalendarInterval = [ { inherit (cfg.schedule) Hour Minute; } ];
            LowPriorityIO = true;
            Nice = 20;
            StandardOutPath = cfg.stdout;
            StandardErrorPath = cfg.stderr;
            TimeOut = 600;
          };
        };
      }
    );
}

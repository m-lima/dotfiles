{
  lib,
  ...
}: {
  mkDisableOption = name: lib.mkOption {
      default = true;
      description = "Whether to enable ${name}.";
      example = false;
      type = lib.types.bool;
    };
  mkIfUi = config: condition: lib.mkIf (config.modules.ui.enable && condition);
}

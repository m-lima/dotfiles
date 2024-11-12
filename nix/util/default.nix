{
  lib,
  ...
}:
let
  mkDisableOption = name: lib.mkOption {
      default = true;
      description = "Whether to enable ${name}.";
      example = false;
      type = lib.types.bool;
    };

  mkIfUi = config: condition: lib.mkIf (config.modules.ui.enable && condition);

  mkIfUiSimple = config: mkIfUi config true;

  mkColorOption = name: default: lib.mkOption {
    type = lib.types.nonEmptyStr;
    description = "Color in hex for `${name}`";
    default = default;
    example = "ffa500";
  };
in {
  inherit
    mkDisableOption
    mkIfUi
    mkIfUiSimple
    mkColorOption
  ;
}

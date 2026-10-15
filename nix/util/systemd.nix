{ lib }:
let
  baseConfig = {
    UMask = "0077";
    NoNewPrivileges = true;
    LockPersonality = true;
    RemoveIPC = true;
    MemoryDenyWriteExecute = true;
    ProcSubset = "pid";
    DevicePolicy = "closed";

    RestrictRealtime = true;
    RestrictNamespaces = true;
    RestrictSUIDSGID = true;
    RestrictAddressFamilies = "none";

    ProtectClock = true;
    ProtectSystem = "strict";
    ProtectProc = "invisible";
    ProtectHome = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectHostname = true;
    ProtectKernelTunables = true;

    PrivateDevices = true;
    PrivateTmp = true;
    PrivateNetwork = true;
    PrivateUsers = true;
    PrivateMounts = true;

    AmbientCapabilities = "";
    CapabilityBoundingSet = "";

    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "~@clock"
      "~@aio"
      "~@chown"
      "~@cpu-emulation"
      "~@debug"
      "~@keyring"
      "~@memlock"
      "~@module"
      "~@mount"
      "~@obsolete"
      "~@privileged"
      "~@raw-io"
      "~@reboot"
      "~@setuid"
      "~@swap"
      "~@resources"
    ];

  };
in
{
  inherit baseConfig;

  harden =
    opts:
    baseConfig
    // (lib.optionalAttrs (!builtins.hasAttr "IPAddressAllow" opts) { IPAddressDeny = "any"; })
    // (lib.optionalAttrs (!builtins.hasAttr "User" opts) { DynamicUser = true; })
    // opts;

  base = lib.mapAttrs (_: v: lib.mkOverride 2000 v) baseConfig;
}

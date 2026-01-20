{ lib }:
{
  harden =
    opts:
    let
      base = {
        UMask = "0077";
        NoNewPrivileges = true;
        LockPersonality = true;
        RemoveIPC = true;
        MemoryDenyWriteExecute = true;
        IPAddressDeny = "any";
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

        # RootDirectory = cfg.home;
        # InaccessiblePaths = [ "-+${cfg.home}" ];
        # BindReadOnlyPaths = [
        #   builtins.storeDir
        # ];

        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
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
    base
    // (lib.optionalAttrs (!builtins.hasAttr "IPAddressAllow" opts) { IPAddressDeny = "any"; })
    // opts;
}

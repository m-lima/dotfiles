path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  xdg = util.xdg config;
  paths =
    let
      name = "lmms";
    in
    rec {
      data = "${xdg.abs "dataHome"}/${name}";
      dataRel = "${xdg.rel "dataHome"}/${name}";
      creation = "${config.celo.modules.core.user.homeDirectory}/creation/${name}";
      lmmsrc = "${data}/lmmsrc.xml";
    };
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = config.services.pipewire.enable;
        message = "LMMS requires pipewire to function";
      }
    ];

    home-manager = {
      home =
        let
          lmms = pkgs.symlinkJoin {
            name = "lmms-wrapped";
            paths = [ pkgs.lmms ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''wrapProgram $out/bin/lmms --add-flags "-c '${paths.lmmsrc}'"'';
          };
        in
        {
          packages = [ lmms ];
        };
    };

    systemd.user.tmpfiles.rules =
      let
        lmmsrc = pkgs.writeText "lmmsrc.xml" ''
          <?xml version="1.0"?>
          <!DOCTYPE lmms-config-file>
          <lmms configversion="3" version="1.3.0-alpha">
            <app configured="1"/>
            <audioalsa channels="2" device="pipewire"/>
            <audioengine framesperaudiobuffer="256" samplerate="44100" audiodev="ALSA (Advanced Linux Sound Architecture)"/>
            <paths backgroundtheme="" gigdir="${paths.data}/samples/gig/" defaultsf2="" theme="data:/themes/default/" workingdir="${paths.creation}/" sf2dir="${paths.data}/samples/soundfonts/" vstdir="${paths.data}/plugins/vst/" ladspadir="${paths.data}/plugins/ladspa/"/>
          </lmms>
        '';
      in
      [
        ''C "${paths.lmmsrc}" 0644 - - - "${lmmsrc}"''
      ];

    environment.persistence = util.withImpermanence config {
      home.directories = [
        paths.dataRel
        "creation"
      ];
    };
  };
}

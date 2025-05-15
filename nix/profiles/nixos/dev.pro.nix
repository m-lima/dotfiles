{
  programs = {
    neovim = {
      enable = true;
      lsps = [
        "cpp"
        "go"
        "js"
        "lua"
        "nix"
        "python"
        "rust"
      ];
    };
    direnv.enable = true;
  };
}

{
  programs = {
    neovim = {
      enable = true;
      plugins = [
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

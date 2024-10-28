{
  userName,
  ...
}: {
  imports = [ ./base.nix ];
  home-manager.users."${userName}".home.username = userName;
  home-manager.users."${userName}".home.homeDirectory = "/home/${userName}";
}

{
  # Hyprlock needs its own PAM service entry to authenticate the unlock
  # password. Only registered when the waybar shell stack is active; the
  # future noctalia bucket will register its own equivalent.
  flake.modules.nixos.waybar.security.pam.services.hyprlock = { };
}

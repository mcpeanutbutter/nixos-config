{
  # Kernel audit subsystem + userspace auditd daemon, with no rules loaded
  # by default. Cheap to keep around — gives every host a forensics /
  # compliance framework that's ready to use if anything ever needs it.
  flake.modules.nixos.base = {
    security.auditd.enable = true;
    security.audit.enable = true;
  };
}

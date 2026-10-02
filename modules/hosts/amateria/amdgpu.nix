{ lib, ... }:
{
  # nixos-hardware's framework-16-7040-amd only sets dcdebugmask=0x10
  # (DC_DISABLE_PSR). Panel Replay (0x400, DC_DISABLE_REPLAY) stays on, and on
  # 2026-10-02 an eDP link-training failure at idle lock/screen-off wedged the
  # DMCUB inside dmub_replay_get_state, freezing the whole display pipe until a
  # hard reboot. 0x410 matches what nixos-hardware ships for the AI 300 FW16.
  # mkAfter so this lands after the hardware module's 0x10 — the last
  # occurrence on the cmdline wins.
  configurations.nixos.amateria.module.boot.kernelParams = lib.mkAfter [
    "amdgpu.dcdebugmask=0x410"
  ];
}

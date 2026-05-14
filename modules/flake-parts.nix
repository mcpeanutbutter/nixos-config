{ inputs, ... }:
{
  imports = [
    # Provides flake.modules.<class>.<name> as deferredModule containers.
    # https://flake.parts/options/flake-parts-modules.html
    inputs.flake-parts.flakeModules.modules
  ];
}

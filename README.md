
# OneDev NixOS Module

A NixOS module + package for running [OneDev](https://onedev.io/) (self-hosted Git server with built-in CI/CD).

This flake provides:
- A custom `onedev` package (with proper Nix store integration)
- A NixOS module (`services.onedev`) with useful options

## Quick Start

### 1. Add this flake as an input

In your main **flake.nix**:

```nix
{
  inputs = {
    # ... your other inputs ...

    onedev.url = "git+http://onedev:6610/Onedev-Nixos-Flake.git";
    # Or if it's on GitHub: "github:yourusername/onedev-nixos";
  };

  outputs = { self, nixpkgs, onedev, ... }@inputs: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        inherit onedev;   # Important!
      };
      modules = [
        ./configuration.nix
        # ... your other modules
      ];
    };
  };
}
```

### 2. Enable the module

In your machine configuration (e.g. `./Maschines/moab.nix` or `./configuration.nix`):

```nix
{ config, pkgs, onedev, ... }:

{
  imports = [ onedev.nixosModules.default ];   # or onedev.nixosModules.onedev

  services.onedev = {
    enable = true;

    # Optional customizations
    http_port = 6610;
    ssh_port = 6611;
    http_host = "0.0.0.0";
    installDir = "/opt/onedev";

    # You can add more options as they become available
  };

  # Optional: open the firewall
  networking.firewall.allowedTCPPorts = [ config.services.onedev.http_port ];
}
```

### 3. Rebuild your system

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

After rebuilding, OneDev should start automatically.

## Available Options

| Option                  | Type    | Default          | Description                                      |
|-------------------------|---------|------------------|--------------------------------------------------|
| `enable`                | bool    | `false`          | Enable the OneDev service                        |
| `installDir`            | str     | `/opt/onedev/`   | Main directory OneDev uses                       |
| `http_host`             | str     | `0.0.0.0`        | IP address to bind to                            |
| `http_port`             | port    | `6610`           | HTTP port (automatically converted to string)    |
| `ssh_port`              | port    | `6611`           | SSH port for Git access                          |

## How it works internally

- The module uses an **overlay filesystem** to combine the package with generated config files.
- The service runs as root (for simplicity) using `${onedev}/bin/server.sh console`.
- You can customize behavior by overriding options.

## Development / Testing

Inside this repo you can test with:

```bash
nix build .#nixosConfigurations.test-vm.config.system.build.vm   # if you have a test config
```




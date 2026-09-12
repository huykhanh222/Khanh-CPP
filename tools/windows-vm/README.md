# Windows VM for building the portable Windows package

This folder contains a small helper to start a Windows VM in QEMU/KVM so the project's Windows build script can run in a proper Windows environment.

## Requirements

- Linux host with KVM support
- `qemu-system-x86_64` and `qemu-img`
- A legal Windows ISO or VHDX image

## Start the VM

1. Download a legal Windows image.
   - Best option: use the official Microsoft Windows VM page from a browser and save the ISO/VHDX file.
   - For example: `/mnt/data/Win11_English_x64.iso`
2. Launch the VM:

```bash
./tools/windows-vm/run-windows-vm.sh /mnt/data/Win11_English_x64.iso
```

3. Connect with VNC:

```bash
# on the host machine
vncviewer localhost:5901
```

Alternatively, if you want a web browser preview:

```bash
websockify --web=/usr/share/novnc 6080 localhost:5901
```

Then open:

```text
http://localhost:6080/vnc.html
```

## Build inside Windows

Once Windows is installed and MSYS2 + Qt are present, run:

```bash
./packages/mingw/build-xp.sh -p 64-ucrt
```

or the MSVC path:

```powershell
./packages/msvc/build.ps1 -QtDir C:/Qt/6.8.3/msvc2022_64
```

## Why this is needed

The project's official portable Windows build scripts are designed for Windows/MSYS2, not Linux. This VM gives the build a valid target environment.

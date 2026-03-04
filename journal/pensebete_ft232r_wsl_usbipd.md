# Pense-bête — FT232R (0403:6001) dans WSL2 via usbipd

## Windows (PowerShell **admin**)
1) Lister les périphériques USB et repérer l’FTDI (VID:PID `0403:6001`) + son `BUSID` (ex: `7-1`) :

```powershell
usbipd list
```

2) Partager + attacher à WSL (remplacer `7-1`) :

```powershell
usbipd bind --busid 7-1
usbipd attach --wsl --busid 7-1
```

Option auto-attach (si supporté) :

```powershell
usbipd attach --wsl --busid 7-1 --auto-attach
```

3) Détacher (si besoin) :

```powershell
usbipd detach --busid 7-1
```

## WSL (WLinux)
Vérifier l’apparition :

```bash
lsusb
dmesg | tail -n 30
ls -l /dev/ttyUSB*
```

Ouvrir la console série :

```bash
picocom -b 115200 /dev/ttyUSB0
```

Quitter picocom : `Ctrl+A` puis `Ctrl+X`

## Droits d’accès (une seule fois)
```bash
sudo usermod -aG dialout $USER
```

Puis côté Windows :

```powershell
wsl --shutdown
```
(Rouvrir WSL ensuite.)

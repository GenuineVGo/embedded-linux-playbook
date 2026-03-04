# Pense-bête — SSH Buildroot RPi4 (host key changed, alias)

## Connexion (Windows)
- Alias conseillé dans `C:\Users\puban\.ssh\config` :

```sshconfig
Host rpi4
  HostName 192.168.137.6
  User root
```

Connexion :
```powershell
ssh rpi4
```

## Si “REMOTE HOST IDENTIFICATION HAS CHANGED”
(typiquement après reflash → nouvelle host key)

```powershell
ssh-keygen -R 192.168.137.6
ssh rpi4
```
Puis répondre `yes` au prompt d’authenticité.

## Côté cible (permissions clés)
```sh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

## Vérifs rapides sur la cible
```sh
ip -4 a show eth0
ip r
ps | grep dropbear | grep -v grep
netstat -tln | grep ':22'
```

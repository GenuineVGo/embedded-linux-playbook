# Objectifs — Rootfs A/B (Yocto / RPi4)

## Contexte
- Cible : Raspberry Pi 4 (machine `raspberrypi4-64`, Poky/Yocto).
- Support de boot : SD avec partitions A/B + data persistante.
- Objectif : déployer des mises à jour **sans reflasher** toute la carte, avec **rollback** simple.
- Stratégie retenue : **A1 (WKS custom)** — le `.wic` doit créer **p1+p2+p3+p4** dès le provisioning initial.

---

## 1) Objectifs fonctionnels

### 1.1 Boot A/B
- Le système doit pouvoir booter indifféremment sur :
  - **rootfsA** (partition p2)
  - **rootfsB** (partition p3)
- La sélection A/B doit se faire via **`root=PARTUUID=...`** dans `cmdline.txt` (robuste même après réécriture `dd` du filesystem).

### 1.2 Mise à jour sans reflash complet
- Yocto doit produire un artefact **`rootfs.ext4`** pour permettre :
  - écriture directe sur la partition **inactive** (p2 ou p3)
  - exécution rapide : `dd if=rootfs.ext4 of=/dev/mmcblk0pX`
- Le `.wic` reste utile pour “reprovisioning” complet, mais **n’est pas le flux nominal** d’update.

### 1.3 Rollback
- Rollback manuel minimal :
  - repointer `root=PARTUUID=...-02` ↔ `...-03` dans `cmdline.txt` + reboot.
- Rollback automatique (phase 2) :
  - si le boot “nouveau slot” n’est pas validé (healthcheck), rebascule vers l’ancien slot au boot suivant.

---

## 2) Objectifs de persistance (données)

### 2.1 Partition data dédiée
- Une partition **data persistante** (p4) doit être montée sur `/data` sur **A** et **B**.
- `/data` contient tout ce qui ne doit pas être perdu lors d’une réécriture du rootfs :
  - configuration runtime
  - clés (si besoin)
  - logs persistants
  - cache applicatif

### 2.2 Montage robuste de /data
- Le montage doit être indépendant du rootfs (A ou B).
- Recommandation :
  - montage via **LABEL=data** (préférable en dev) ou UUID fixe
  - exemple fstab : `LABEL=data  /data  ext4  defaults,noatime  0  2`

### 2.3 Zéro bricolage local
- Le montage `/data` ne doit pas dépendre d’une modification manuelle de `/etc/fstab` après flash.
- Il doit être **intégré dans l’image Yocto** (via layer `meta-vincent` ou bbappend standard).
- Conséquence : **rootfsA/rootfsB sont jetables** (écrasés par `dd`), donc toute persistance doit vivre dans `/data` (ou être régénérée au boot).

---

## 3) Invariants “accès & réseau” (dev-grade)

### 3.1 Accès SSH reproductible
- SSH doit fonctionner sur **A** et **B** dès le premier boot :
  - Dropbear (ou OpenSSH, mais rester cohérent)
  - auth par **clé** (`authorized_keys`) intégrée à l’image
- Éviter les prompts `known_hosts` en dev :
  - accepter qu’un reflash change la host key, ou
  - (optionnel) stabiliser host keys via `/data` (phase 2).

### 3.2 Découverte réseau
- Avahi + mDNS opérationnels sur A et B :
  - accès via `rpi4-yocto.local` sans dépendre d’une IP fixe
- DHCP client OK.

### 3.3 UART boot log
- UART activée (console) pour debug (utile en phase bootstrap/rollback).

---

## 4) Artefacts Yocto attendus

### 4.1 Formats
- `IMAGE_FSTYPES` doit produire :
  - `.wic` (reprovisioning complet **avec layout A/B/data**)
  - `.ext4` (update rootfs-only)

Exemple :

```conf
IMAGE_FSTYPES:append = " wic ext4"
```

### 4.2 Scripts/targets de déploiement (repo)
Cibles Makefile attendues (ou scripts) :

- `flash-yocto-full` : flash du `.wic` sur SD (**doit produire p1/p2/p3/p4** via WKS custom)
- `flash-yocto-rootfsA` : écrit `rootfs.ext4` sur p2
- `flash-yocto-rootfsB` : écrit `rootfs.ext4` sur p3
- `flip-rootfs` : modifie `cmdline.txt` pour basculer A↔B (PARTUUID)
- `status-rootfs` : affiche root courant + PARTUUID A/B + état `/data`

---

## 5) Layout SD attendu (référence)
- p1 : boot (FAT), contient `cmdline.txt`
- p2 : rootfsA (ext4)
- p3 : rootfsB (ext4)
- p4 : data (ext4, `LABEL=data`)

---

## 6) Stratégie retenue : A1 (WKS custom)

### 6.1 Problème du `.wic` RPi4 par défaut
Le `.wic` RPi4 “par défaut” ne crée généralement que **p1 (boot) + p2 (rootfs)**.
Donc sans action supplémentaire, **p3/p4 n’existent pas** et le layout attendu n’est pas atteint.

### 6.2 Attendu
- Un `.wks` (kickstart) versionné dans le repo, utilisé par Yocto pour produire une `.wic` contenant **p1/p2/p3/p4** dès le provisioning initial.
- Résultat : `flash-yocto-full` produit directement le layout attendu.
- (A2 script post-flash existe uniquement comme plan de récupération/migration, pas comme flux nominal.)

---

## 7) `flip-rootfs` et gestion de `/boot` (p1 FAT)

### 7.1 Exigence
`cmdline.txt` est sur **p1 (FAT)**. Le script/target `flip-rootfs` doit :
1) identifier p1 (typiquement `/dev/mmcblk0p1`)
2) monter p1 si nécessaire (ex: `/mnt/boot`)
3) modifier uniquement `root=PARTUUID=...-02` ↔ `...-03` dans `cmdline.txt`
4) `sync`, unmount proprement
5) (option) reboot

### 7.2 Règle d’or
- Boot/rootfs A↔B : **PARTUUID**
- Ne pas utiliser `root=UUID=...` pour A/B : une réécriture `dd` change l’UUID du filesystem.

---

## 8) Flux nominal “dd” : depuis qui ?

### 8.1 Update via réseau (recommandé)
Flux nominal (sans manipulation physique SD) :

1) depuis la machine de build :
   - `scp rootfs.ext4 root@rpi4-yocto.local:/tmp/rootfs.ext4`
2) sur la cible, écrire sur la partition inactive :
   - `dd if=/tmp/rootfs.ext4 of=/dev/mmcblk0p3 bs=4M conv=fsync status=progress`
3) `sync`, puis `flip-rootfs`, puis reboot.

### 8.2 Update offline (secours)
- `dd` direct sur `/dev/sdX2` ou `/dev/sdX3` + édition `cmdline.txt` sur `sdX1` depuis une machine Linux.

---

## 9) Phase 2 (améliorations)
- Boot validation :
  - mécanisme “pending/confirmed” (flag dans `/data`) + rollback si non confirmé
- Host keys persistantes dans `/data` (si besoin)
- Bind-mount de fichiers de config depuis `/data` vers `/etc/...` si config externalisée
- Mise à jour atomique : écrire rootfs sur slot inactif + switch + reboot.

---

## 10) Critères de réussite
- On peut :
  1) booter sur A, écrire B, switch, booter sur B
  2) booter sur B, écrire A, switch, booter sur A
  3) garder `/data` intact à travers tous les cycles
  4) accéder en SSH via `rpi4-yocto.local` sur A et sur B, sans configuration manuelle post-flash

---

## Checklist opérationnelle — Rootfs A/B (Yocto / RPi4)

### 0) Pré-requis
- [ ] SD layout OK : p1 boot, p2 rootfsA, p3 rootfsB, p4 data (`LABEL=data`)
- [ ] `cmdline.txt` utilise `root=PARTUUID=...` (pas UUID, pas `/dev/mmcblk0pX`)

### 1) Build Yocto (artefacts)
- [ ] `IMAGE_FSTYPES:append = " wic ext4"` activé
- [ ] `rootfs.ext4` présent dans `build/tmp/deploy/images/raspberrypi4-64/`
- [ ] `.wic` présent (**provisioning complet p1/p2/p3/p4 via WKS custom**)

### 2) Provisioning initial (1 seule fois)
- [ ] Flasher `.wic` A/B/data sur la SD (p1+p2+p3+p4 créés dès le flash)
- [ ] Vérifier : p4 est `LABEL=data`
- [ ] Vérifier : `cmdline.txt` pointe vers le slot initial via PARTUUID

### 3) Persistance /data
- [ ] `/data` monte automatiquement au boot (fstab livré dans l’image)
- [ ] Vérif : `df -h /data`
- [ ] `lost+found` présent sur /data (OK)
- [ ] Contenu `/data` intact à travers bascules A↔B

### 4) Invariants accès/réseau (A et B)
- [ ] DHCP OK : `ip a` / `ip r` / `cat /etc/resolv.conf`
- [ ] mDNS OK : `rpi4-yocto.local` résout et ping OK
- [ ] SSH OK : `ssh root@rpi4-yocto.local` (clé, pas de mot de passe)
- [ ] Avahi actif : `ps | grep avahi` (sysvinit : pas de systemctl)
- [ ] UART OK : boot visible si besoin

### 5) Cycle update A→B
- [ ] Boot sur A (`cat /proc/cmdline` → PARTUUID=...-02)
- [ ] Copier `rootfs.ext4` sur la cible : `scp ...:/tmp/rootfs.ext4`
- [ ] Écrire sur B : `dd if=/tmp/rootfs.ext4 of=/dev/mmcblk0p3 bs=4M conv=fsync status=progress`
- [ ] `sync`
- [ ] Switch boot vers B : `flip-rootfs` (ou éditer `cmdline.txt`) → `root=PARTUUID=...-03`
- [ ] Reboot
- [ ] Vérif : `cat /proc/cmdline` → PARTUUID=...-03
- [ ] Vérif : `/data` monté + contenu intact

### 6) Cycle update B→A
- [ ] Boot sur B (PARTUUID=...-03)
- [ ] Copier `rootfs.ext4` sur la cible : `scp ...:/tmp/rootfs.ext4`
- [ ] Écrire sur A : `dd if=/tmp/rootfs.ext4 of=/dev/mmcblk0p2 bs=4M conv=fsync status=progress`
- [ ] `sync`
- [ ] Switch boot vers A : `flip-rootfs` → `root=PARTUUID=...-02`
- [ ] Reboot
- [ ] Vérif : PARTUUID=...-02
- [ ] Vérif : `/data` intact

### 7) Rollback (manuel)
- [ ] Si boot KO : repointer `root=PARTUUID=<slot précédent>` dans `cmdline.txt`, reboot
- [ ] SSH known_hosts (après reflash) : `ssh-keygen -R rpi4-yocto.local`

### 8) “Done criteria”
- [ ] 2 bascules consécutives A↔B réussies
- [ ] `/data` intact à chaque bascule
- [ ] SSH + mDNS OK sur A et sur B

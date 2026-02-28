# Boot Flow

## UEFI ↔ Linux embedded parallel

| UEFI | Linux embedded ARM |
|------|--------------------|
| SEC/PEI | Boot ROM + SPL |
| DXE | U-Boot proper |
| BDS | U-Boot bootcmd |
| ACPI tables | Device Tree |

*Content will grow with Phase 1 week 3.*

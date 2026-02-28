# ADR 0001 — Target Selection

## Status
Accepted

## Context
The 90-day plan needs hardware targets for learning. Budget and time are constrained.

## Decision
- **RPi4** as primary target from J1: cheap, well-documented, expendable
- **QEMU aarch64** for build validation without hardware
- **Toradex Verdin iMX8M Plus** as optional industrial target, decision deferred to J45

## Rationale
RPi4 maximizes learning velocity. Toradex adds NXP BSP reality but is only relevant if the career target involves i.MX. Deferring the purchase avoids premature investment.

## Consequences
- The repo starts with `targets/rpi4/` and `targets/qemu-aarch64/` only
- `targets/verdin-imx8mp/` is created if and when the decision is made
- All exercises must work on RPi4 first

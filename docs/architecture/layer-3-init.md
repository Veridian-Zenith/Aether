# Layer 3: Init System

## Current = systemd
## Future = `aether-init` (systemd-compatible config, no glibc dependency)

---

## Decisions

| Property | Decision |
|----------|----------|
| First boot init | systemd |
| Future init | Custom C++, reads systemd-styled unit files, minimal, no glibc |
| WiFi | IWD with built-in DHCP |
| Wired | systemd-networkd (default); user-selectable at install |
| Service format | systemd unit files (both now and future) |
| Journal | systemd-journald (now); structured log format (future) |

---

## Current Stack (systemd)

```
kernel → initramfs → systemd (PID 1)
                         │
                         ├─ systemd-journald     ← logs
                         ├─ systemd-networkd     ← wired DHCP
                         ├─ systemd-resolved     ← DNS
                         ├─ systemd-timedated    ← time
                         ├─ systemd-logind       ← sessions
                         ├─ systemd-udevd        ← device mgmt
                         ├─ systemd-sysusers     ← users
                         └─ systemd-tmpfiles     ← /tmp /run
                         
              iwd ← WiFi + built-in DHCP
```

### Services enabled by default:
```
systemd-networkd.service     ← wired networking
systemd-resolved.service     ← DNS (stub resolver)
iwd.service                  ← WiFi
systemd-oomd.service         ← OOM handling
systemd-timesyncd.service    ← NTP
```

### Services NOT enabled:
```
systemd-boot-update.service  ← handled by aether-merge
systemd-journal-upload       ← not needed
systemd-journal-remote       ← not needed
systemd-coredump             ← not needed by default
systemd-ask-password-console ← plymouth handles this
```

---

## Network Architecture

### WiFi: IWD

- Built-in DHCP enabled (`[General].EnableNetworkConfiguration=true`)
- No dhcpcd, no wpa_supplicant
- Config: `/etc/iwd/`

```
/etc/iwd/
├── main.conf                  ← EnableNetworkConfiguration=true
└── <ssid>.psk                 ← per-network credentials
```

### Wired: systemd-networkd

```
/etc/systemd/network/
├── 20-wired.network           ← DHCP on enp*
└── 10-virtual.network         ← loopback
```

### User-selectable at install:
- `aether install --network=iwd-only` — IWD handles everything
- `aether install --network=systemd` — systemd-networkd for wired, iwd for WiFi
- `aether install --network=iwd+dhcpcd` — legacy fallback

---

## Future: `aether-init`

### Requirements:
- Written in C++, links against llvm-libc (no glibc)
- Reads systemd unit files (`.service`, `.timer`, `.socket`, `.target`)
- No D-Bus dependency
- No udev dependency (use netlink directly or minimal devfs)
- Single binary, ~1MB stripped
- Socket activation (via `AF_UNIX` and `AF_INET` listeners in unit files)
- Timer units (via `timerfd`)
- Parallel service startup (dependency graph resolved at load)

### NOT included (use separate tools):
- logind → minimal PAM + seatd
- journald → structured log writer, tool to read
- timedated → simple timedatectl replacement
- resolved → stub resolver via systemd-resolved or minimal musl-based resolver

### Config path: `/etc/aether-init/`

```
/etc/aether-init/
├── units/                     ← symlinked to /usr/lib/aether-init/units/
│   ├── basic.target
│   ├── multi-user.target
│   └── getty@.service
├── system.conf               ← global defaults (default timeout, env)
└── preset/                    ← enabled/disabled lists
```

### Journal format (future):

Structured binary log per-service, written to `/var/log/aether/`:
```
/var/log/aether/
├── system/                    ← PID 1 logs
├── sshd/                      ← per-service
├── iwd/
└── cursor                    ← monotonic cursor for journalctl-like tool
```

Binary format: CBOR or flatbuffers. Tool `aether-log` reads/filters/tails.

---

## Phase 3 Implementation Steps

| # | Step | Output |
|---|------|--------|
| 1 | systemd build into sysroot | `base/scripts/systemd.sh` (stub exists) |
| 2 | IWD build | `base/scripts/iwd.sh` |
| 3 | Enable services in config | `base/scripts/config-system.sh` (partially done) |
| 4 | Test: boot to systemd → iwd → fish prompt | First milestone targets this |
| 5 | Design aether-init unit file format | Spec document |
| 6 | Prototype aether-init as userspace process | Runs alongside systemd initially |
| 7 | Replace systemd with aether-init | Self-hosting milestone |

---

## Comparison: systemd units → aether-init units

```
systemd:                             aether-init (future):

[Unit]                               unit:
Description=SSH daemon                 name: sshd
After=network.target                   description: SSH daemon
                                       after: [network]

[Service]                            exec:
ExecStart=/usr/bin/sshd -D             start: /usr/bin/sshd -D
Restart=on-failure                     restart: on-failure
Type=notify                            notify: yes

[Install]                            install:
WantedBy=multi-user.target             wanted-by: [multi-user]
```

No `[Install]` section parsing — aether-init reads symlink farms from `/etc/aether-init/units/` like systemd's `Wants=` directories.

---

## Rationale

systemd works and is well-understood. Shipping it for first boot removes risk. The long-term goal is aether-init because:

1. **No glibc dependency** — breaks the glibc chain for PID 1
2. **Smaller** — sub-1MB vs. systemd's multi-MB footprint
3. **Simpler config** — TOML/YAML-inspired format, no DBus introspection
4. **Ownership** — can fix bugs, add features, audit every line

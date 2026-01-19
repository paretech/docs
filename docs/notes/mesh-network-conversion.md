# Mesh Wi-Fi Transition

Purpose: Safely migrate from a single ISP-provided Wi-Fi AP to a Deco mesh system while minimizing user disruption and preserving rollback paths. This is a risk adverse strategy.

---

## Phase 0 — Prepare

**Goal:** Avoid surprises and lockouts

- [ ] Confirm current SSID **exact spelling** and password
- [ ] Record ISP gateway admin IP and login credentials
- [ ] Confirm **no Ethernet-dependent devices** (printers, NAS, desktops)
- [ ] Install Deco app and familiarize yourself with UI flow
- [ ] Identify Deco install locations (QTY 3)
  - [ ] One node per floor
  - [ ] Nodes roughly above/below each other (best effort)
  - [ ] Node near electrical outlet (and ideally network cable)
  - [ ] Prefer node in open transitions (e.g., stairwell)
  - [ ] Avoid node in mechanical rooms, cabinets, dense obstructions

---

## Phase 1 — Preserve Rollback Path

**Goal:** Keep old network reachable while staging new one

- [ ] Log into ISP Modem / Router / AP
- [ ] Rename Wi-Fi SSID  `<SSID>` → `<SSID>-OLD`
- [ ] Leave password unchanged
- [ ] Do **not** disable radios (yet, Phase 4)
- [ ] Verify primary admin device can connect to `<SSID>-OLD`
- [ ] Verify ISP admin UI is still reachable

---

## Phase 2 — Install Mesh Network

**Goal:** Seamless client migration, avoid double NAT

- [ ] Connect Deco #1 via Ethernet to ISP LAN port
- [ ] In Deco app:
  - [ ] Set **Operation Mode → Access Point**
  - [ ] Create Wi-Fi using **original `<SSID>` + original password**
  - [ ] Leave band steering and fast roaming enabled
- [ ] Install remaining Deco nodes (one per floor, see Phase 0)

### Critical Checks

- [ ] Client IPs still in ISP subnet
- [ ] Default gateway is the same as ISP gateway IP
- [ ] Walk test between floors (e.g., no drops during video call)

---

## Phase 3 — Evaluation Period (1–4 Weeks)

**Goal:** Confirm network stability before policy changes

- [ ] Basement streaming works reliably
- [ ] Smart TVs behave normally
- [ ] No recurring “Wi-Fi is weird” complaints
- [ ] Deco app shows all nodes stable and online

---

## Phase 4 — Cleanup + Policy Hardening

**Goal:** Reduce RF clutter and apply DNS safely

### DNS Change (recommended)

- [ ] On ISP gateway only:
  - [ ] Primary DNS: `9.9.9.9`
  - [ ] Secondary DNS: `149.112.112.112`

### Old Wi-Fi Retirement

- [ ] Disable ISP Wi-Fi radios **or**
- [ ] Hide SSID and set strong password
- [ ] Confirm ISP admin UI still reachable via Deco network

### Final Cleanup

- [ ] Reboot ISP gateway once
- [ ] Reboot Deco nodes via app
- [ ] Spot-check internet access

---

## Recovery Rules

- If something breaks → **re-enable `<SSID>-OLD`**
- Never disable DHCP on ISP gateway
- Never enable bridge mode on ISP gateway
- Deco must remain in **Access Point mode**

---

## End State

ISP gateway remains network controller (DHCP + routing).  
Deco provides whole-home Wi-Fi coverage without double NAT.

---

## Resources

- [Deco XE75 Hot Buys AXE5400 Tri-Band Mesh Wi-Fi 6E System](https://www.tp-link.com/us/deco-mesh-wifi/product-family/deco-xe75/v1%20(3-pack)/) ($220 [@Amazon](https://www.amazon.com/TP-Link-Deco-AXE5400-Tri-Band-XE75/dp/B0B88T5RDY))

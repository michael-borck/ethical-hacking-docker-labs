#!/usr/bin/env python3
"""Generate an SVG network map for each module from docker-compose.yml.

The topology is read live from `docker compose --profile module-NN config`, so the
diagrams never drift from the actual labs. Output: docs/diagrams/module-NN.svg
(theme-aware, matches the lab design system).

Usage:  python3 tools/gen-netmap.py            # all modules
        python3 tools/gen-netmap.py 07 02      # just these
"""
import json, subprocess, sys, ipaddress, os

MODULES = ["01","03","04","05","06","07","08","09","10","11","12"]  # weeks with a compose (2 is docs-only)
OUTDIR = "docs/diagrams"
W = 880

TINTS = [  # (zone fill var, zone stroke var) cycled per network
    ("var(--z1)", "var(--z1l)"),
    ("var(--z2)", "var(--z2l)"),
    ("var(--z3)", "var(--z3l)"),
]
SPECIAL = ("attacker", "analyst", "station", "firewall")

def esc(s): return str(s).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")

def config(nn):
    import glob
    w = f"labs/week{int(nn)}"
    files = glob.glob(f"{w}/docker-compose.yml") + glob.glob(f"{w}/docker-compose.yaml")
    if not files:
        raise SystemExit(f"no compose for week {nn}")
    r = subprocess.run(["docker","compose","-f",files[0],"config","--format","json"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit(f"compose config failed for week-{nn}: {r.stderr[:300]}")
    return json.loads(r.stdout)

def model(cfg):
    services = cfg.get("services", {}) or {}
    used = []
    svcs = []
    for name, s in services.items():
        nets = s.get("networks") or {}
        netmap = {}
        if isinstance(nets, dict):
            for n, nd in nets.items():
                netmap[n] = (nd or {}).get("ipv4_address", "")
                if n not in used: used.append(n)
        # published host ports (for browser access)
        hostports = []
        for p in s.get("ports", []) or []:
            if isinstance(p, dict) and p.get("published"): hostports.append(str(p["published"]))
            elif isinstance(p, str) and ":" in p: hostports.append(p.split(":")[0])
        svcs.append({
            "name": name,
            "disp": s.get("hostname") or name,
            "nets": netmap or {"default": ""},
            "ports": hostports,
            "role": next((r for r in SPECIAL if r in (s.get("hostname") or name).lower()), None),
        })
        if not netmap and "default" not in used: used.append("default")
    nets = {}
    for n in used:
        nd = (cfg.get("networks", {}) or {}).get(n, {}) or {}
        subnet = ""
        for c in (nd.get("ipam", {}) or {}).get("config", []) or []:
            if c.get("subnet"): subnet = c["subnet"]
        gw = ""
        if subnet:
            try: gw = str(ipaddress.ip_network(subnet).network_address + 1)
            except Exception: pass
        nets[n] = {"subnet": subnet or "docker bridge", "gw": gw}  # gw "" when unknown (default net)
    return svcs, nets

# ---- SVG pieces ----------------------------------------------------------
def device(x, y, host, line2, special=False, port=None):
    cls = "dev fw" if special else "dev"
    dotcls = "dot fwdot" if special else "dot"
    s = f'<g><rect class="{cls}" x="{x}" y="{y}" width="168" height="58" rx="10"/>'
    s += f'<circle class="{dotcls}" cx="{x+18}" cy="{y+20}" r="4"/>'
    s += f'<text class="host" x="{x+32}" y="{y+25}">{esc(host)}</text>'
    s += f'<text class="ip" x="{x+14}" y="{y+45}">{esc(line2)}</text>'
    if port:
        s += f'<text class="port" x="{x+14}" y="{y-8}">browser → localhost:{esc(port)}</text>'
    s += '</g>'
    return s

def internet(cx, cy):
    return (f'<g><rect class="net-cloud" x="{cx-58}" y="{cy-18}" width="116" height="36" rx="18"/>'
            f'<text class="cloud-t" x="{cx}" y="{cy+5}" text-anchor="middle">☁ Internet</text></g>')

# ---- layouts -------------------------------------------------------------
def layout_two_networks(svcs, nets):
    """Firewall-style: two zones, dual-homed bridge in the middle."""
    net_names = list(nets.keys())
    left, right = net_names[0], net_names[1]
    bridges = [s for s in svcs if len(s["nets"]) > 1]
    lefts = [s for s in svcs if list(s["nets"])[0] == left and len(s["nets"]) == 1]
    rights = [s for s in svcs if list(s["nets"])[0] == right and len(s["nets"]) == 1]
    rows = max(len(lefts), len(rights), 2)
    H = 150 + rows * 92 + 36          # extra bottom padding so gateway label clears devices
    zh = H - 120
    body = internet(W/2, 40)
    # dashed route-out from each gateway to internet
    body += f'<path class="route" d="M150 {H-40} V70 H{W/2-58}"/>'
    body += f'<path class="route" d="M{W-150} {H-40} V70 H{W/2+58}"/>'
    for i,(nm, x) in enumerate([(left,24),(right,W-274)]):
        body += f'<rect class="zone {["z-a","z-b"][i]}" x="{x}" y="80" width="250" height="{zh}" rx="16"/>'
        body += f'<text class="ztitle" x="{x+20}" y="108">{esc(nm.split("-")[-1].upper())} · {esc(nets[nm]["subnet"])}</text>'
        gwtxt = f'gateway {nets[nm]["gw"]}' if nets[nm]["gw"] else "gateway"
        body += f'<text class="gw" x="{x+20}" y="{80+zh-16}">{esc(gwtxt)}</text>'
    railL, railR = 250, W-274
    body += f'<line class="rail" x1="{railL}" y1="120" x2="{railL}" y2="{80+zh-30}"/>'
    body += f'<line class="rail" x1="{railR}" y1="120" x2="{railR}" y2="{80+zh-30}"/>'
    def place(lst, x, rail, connect_right):
        for i,s in enumerate(lst):
            y = 130 + i*92
            ip = list(s["nets"].values())[0] or ""
            body_dev = device(x, y, s["disp"], ip, s["role"]=="firewall")
            cx = x+168 if connect_right else x
            yield body_dev + f'<path class="link" d="M{cx} {y+29} H{rail}"/>'
    for e in place(lefts, 48, railL, True): body += e
    for e in place(rights, W-274+26, railR, False): body += e
    # bridge (firewall) in the middle
    for b in bridges:
        bx, by = W/2-84, 80 + zh/2 - 54
        ips = " ".join(v for v in b["nets"].values() if v)
        sub = "routes + filters" if b["role"] == "firewall" else "on the path"
        body += (f'<rect class="fw" x="{bx}" y="{by}" width="168" height="108" rx="14"/>'
                 f'<text class="fwt" x="{W/2}" y="{by+34}" text-anchor="middle">{esc(b["disp"].upper())}</text>'
                 f'<text class="fws" x="{W/2}" y="{by+56}" text-anchor="middle">{sub}</text>')
        for j,(nn,ip) in enumerate([kv for kv in b["nets"].items() if kv[1]]):
            body += f'<text class="ip" x="{W/2}" y="{by+78+j*16}" text-anchor="middle">{esc(ip)}</text>'
        body += f'<path class="link" d="M{bx} {by+54} H{railL}"/><path class="link" d="M{bx+168} {by+54} H{railR}"/>'
    return H, body

def layout_bus(svcs, nets):
    """One network: a labelled zone holding a grid of machines. Scales to many."""
    net = list(nets.keys())[0]
    n = len(svcs)
    cols = 1 if n == 1 else (2 if n <= 4 else 3)
    rows = (n + cols - 1)//cols
    cw, ch, gx, gy = 168, 58, 26, 22
    grid_w = cols*cw + (cols-1)*gx
    x0 = (W - grid_w)//2
    ztop, zpad = 96, 26
    zh = zpad + rows*ch + (rows-1)*gy + zpad + 14
    H = ztop + zh + 24
    body = internet(W-90, 46)
    body += f'<rect class="zone z-a" x="40" y="{ztop}" width="{W-80}" height="{zh}" rx="16"/>'
    body += f'<text class="ztitle" x="64" y="{ztop+28}">LAB NETWORK · {esc(nets[net]["subnet"])}</text>'
    gwtxt = f'gateway {nets[net]["gw"]} → internet' if nets[net]["gw"] else "gateway → internet"
    body += f'<text class="gw" x="64" y="{ztop+zh-14}">{esc(gwtxt)}</text>'
    body += f'<path class="route" d="M{W-90} 64 V{ztop}"/>'
    for i, s in enumerate(svcs):
        r, c = divmod(i, cols)
        x = x0 + c*(cw+gx)
        y = ztop + zpad + 14 + r*(ch+gy)
        ip = list(s["nets"].values())[0] or "(on the lab network)"
        port = s["ports"][0] if s["ports"] else None
        body += device(x, y, s["disp"], ip, s["role"] in ("attacker","firewall"), port)
    return int(H), body

def build(nn):
    svcs, nets = model(config(nn))
    if len(nets) >= 2:
        H, body = layout_two_networks(svcs, nets)
    else:
        H, body = layout_bus(svcs, nets)
    style = """
    .zone{fill:var(--surface);stroke:var(--line);stroke-width:1.5}
    .z-a{fill:var(--z1);stroke:var(--z1l)} .z-b{fill:var(--z2);stroke:var(--z2l)}
    .ztitle,.bus-t{font:700 12px system-ui;letter-spacing:.05em;fill:var(--muted)}
    .gw{font:11px ui-monospace,Menlo,monospace;fill:var(--muted)}
    .rail,.bus{stroke:var(--line);stroke-width:2}
    .link{stroke:var(--accent);stroke-width:2;fill:none}
    .route{stroke:var(--muted);stroke-width:1.5;stroke-dasharray:4 4;fill:none;opacity:.7}
    .dev{fill:var(--surface);stroke:var(--line);stroke-width:1.5}
    .fw,.dev.fw{fill:var(--accent-soft);stroke:var(--accent);stroke-width:2}
    .host{font:700 15px ui-monospace,Menlo,monospace;fill:var(--ink)}
    .ip{font:12px ui-monospace,Menlo,monospace;fill:var(--muted)}
    .port{font:11px system-ui;fill:var(--accent)}
    .dot{fill:var(--muted)} .fwdot{fill:var(--accent)}
    .fwt{font:800 14px system-ui;fill:var(--accent);letter-spacing:.04em}
    .fws{font:11px system-ui;fill:var(--muted)}
    .net-cloud{fill:var(--surface);stroke:var(--line);stroke-width:1.5}
    .cloud-t{font:600 12px system-ui;fill:var(--muted)}
    """
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
           f'font-family="system-ui" role="img" aria-label="Network map for week {nn}">'
           '<defs><style>'
           ':root{--surface:#fff;--ink:#14202e;--muted:#5b6775;--line:#c7d0dd;--accent:#256b64;'
           '--accent-soft:#d7ebe8;--z1:#e9f2ff;--z1l:#9cc0ef;--z2:#fdeee6;--z2l:#e6b48f;--z3:#e7f6ec;--z3l:#9dccae;}'
           '@media(prefers-color-scheme:dark){:root{--surface:#161f2c;--ink:#e6ecf3;--muted:#93a1b1;'
           '--line:#324357;--accent:#52b3a8;--accent-soft:#123531;--z1:#13233a;--z1l:#2f5680;'
           '--z2:#301f18;--z2l:#7a5237;--z3:#12271b;--z3l:#2f5c40;}}'
           f'{style}</style></defs>'
           f'<rect width="{W}" height="{H}" fill="var(--surface)" opacity="0"/>'
           f'{body}</svg>')
    os.makedirs(OUTDIR, exist_ok=True)
    with open(f"{OUTDIR}/week-{nn}.svg", "w") as f:
        f.write(svg)
    print(f"  week-{nn}.svg  ({len(svcs)} machines, {len(nets)} network(s))")

if __name__ == "__main__":
    targets = sys.argv[1:] or MODULES
    print("Generating network maps -> docs/diagrams/")
    for nn in targets:
        build(nn)

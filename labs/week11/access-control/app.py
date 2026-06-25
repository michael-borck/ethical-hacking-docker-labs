#!/usr/bin/env python3
"""access-control/app.py - Simulated building badge reader (Python stdlib only).

EDUCATIONAL USE ONLY. Real RFID/NFC cloning (Proxmark3, Flipper Zero, ...) needs
physical hardware and cannot run in Docker. This HTTP service models the backend
logic of a card-access system so the same thinking - badge enumeration,
replay/cloning, and a vendor-default master UID - can be practised in a sandbox.
"""
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

# --- Configuration ---------------------------------------------------------
BADGE_FILE = "/app/valid_badges.txt"      # enrolled employee badges
LOG_FILE = "/app/access.log"              # every tap is logged here
PORT = 80
# Hidden vendor-default "maintenance master" UID - a backdoor shipped by the
# manufacturer and never changed at install. Bypasses all normal checks.
VENDOR_MASTER = "DEAD:BE:EF"
READER_INFO = {  # exposed by GET /status (this is the fingerprinting surface)
    "vendor": "ACME Access Systems",
    "model": "GateKeeper-2000",
    "firmware": "1.4.2",
    "uid_format": "FACILITY:SUBSYS:ID (hex, e.g. 04A2:1B:2F)",
}


def load_badges():
    """Read enrolled badge UIDs (one per line; '#' starts a comment)."""
    out = set()
    with open(BADGE_FILE) as f:
        for line in f:
            line = line.split("#", 1)[0].strip()
            if line:
                out.add(line.upper())
    return out


def log_attempt(uid, granted, detail=""):
    """Append every badge tap to the access log (readable once reader is owned)."""
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    flag = "GRANTED" if granted else "DENIED"
    with open(LOG_FILE, "a") as f:
        f.write(f"{ts} uid={uid.upper()} result={flag} {detail}\n")


VALID = load_badges()
# Seed the log with past taps by employees the attacker has NOT enumerated yet,
# so dumping the log from a compromised reader reveals extra credentials.
for _uid, _who in [("04A2:9F:11", "dana/finance"),
                   ("04A2:9F:42", "eric/exec"),
                   (VENDOR_MASTER, "<vendor-master>")]:
    log_attempt(_uid, True, f"seed/{_who}")


class Reader(BaseHTTPRequestHandler):
    def _send(self, code, body):
        self.send_response(code)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(body.encode())

    def do_GET(self):
        p = urlparse(self.path)
        if p.path == "/status":                          # fingerprint the reader
            info = "\n".join(f"{k}: {v}" for k, v in READER_INFO.items())
            self._send(200, f"[OK] reader online\n{info}\nenrolled_badges: {len(VALID)}\n")
        elif p.path == "/diag":                          # hidden maint port
            # A *valid* badge dumps the access log - models pulling creds off a
            # physically compromised reader (e.g. its debug/serial service port).
            uid = parse_qs(p.query).get("uid", [""])[0].upper()
            if uid == VENDOR_MASTER or uid in VALID:
                try:
                    data = open(LOG_FILE).read()
                except FileNotFoundError:
                    data = "(no log)"
                log_attempt(uid, True, "diag/log-dump")
                self._send(200, f"[DIAG] credential dump for {uid}:\n{data}\n")
            else:
                log_attempt(uid, False, "diag/forbidden")
                self._send(403, "[DENIED] diag requires a valid badge\n")
        else:
            self._send(404, "[404] unknown endpoint\n")

    def do_POST(self):
        p = urlparse(self.path)
        if p.path != "/present":
            self._send(404, "[404] unknown endpoint\n")
            return
        uid = parse_qs(p.query).get("uid", [""])[0].upper()
        if not uid:
            self._send(400, "[ERR] POST /present?uid=FACILITY:SUBSYS:ID required\n")
            return
        if uid == VENDOR_MASTER:                         # vendor backdoor
            log_attempt(uid, True, "present/vendor-master")
            self._send(200, "[GRANTED] ACCESS GRANTED (maintenance master) - door unlocked\n")
        elif uid in VALID:                               # normal enrolled badge
            log_attempt(uid, True, "present/valid")
            self._send(200, "[GRANTED] ACCESS GRANTED - door unlocked\n")
        else:                                            # unknown badge
            log_attempt(uid, False, "present/unknown")
            self._send(403, "[DENIED] badge not recognised - door remains locked\n")

    def log_message(self, *a):                           # silence default stderr noise
        pass


if __name__ == "__main__":
    print(f"ACME GateKeeper-2000 reader up on :{PORT} ({len(VALID)} badges enrolled)")
    HTTPServer(("0.0.0.0", PORT), Reader).serve_forever()

#!/usr/bin/env python3
"""
Minimal login server for the Week 6 password-attack lab.

python3 -m http.server only implements GET/HEAD, so a plain static HTML
login form can never actually be "attacked" — every POST just gets a
501 Unsupported method response, with no pass/fail signal at all.

This tiny server implements do_POST so tools like Hydra's
http-post-form module have a real success/failure response to detect.

Valid credentials (intentionally weak, for the lab): admin / letmein
"""
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs

VALID_USER = "admin"
VALID_PASS = "letmein"

LOGIN_FORM = """<html><body>
<h1>Login Page</h1>
<form method="post" action="/login">
<input name="user">
<input type="password" name="pass">
<button>Login</button>
</form>
</body></html>"""


class LoginHandler(BaseHTTPRequestHandler):
    def _send(self, status, body):
        self.send_response(status)
        self.send_header("Content-Type", "text/html")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body.encode())

    def do_GET(self):
        self._send(200, LOGIN_FORM)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode()
        fields = parse_qs(body)
        user = fields.get("user", [""])[0]
        pwd = fields.get("pass", [""])[0]

        if user == VALID_USER and pwd == VALID_PASS:
            self._send(200, "<html><body>Welcome, login successful!</body></html>")
        else:
            # Deliberate, stable string for Hydra's -f / F= failure match
            self._send(200, "<html><body>Invalid username or password</body></html>")

    def log_message(self, format, *args):
        pass  # keep container logs quiet


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 80), LoginHandler).serve_forever()

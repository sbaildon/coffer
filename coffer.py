#!/usr/bin/env python3

import glob
import os
import re
import socket
import struct
import subprocess
import sys

CREDENTIALS_DIRECTORY = os.environ["CREDENTIALS_DIRECTORY"]
STATE_DIRECTORY = os.environ["STATE_DIRECTORY"]

def post(name):
    flags = []

    for f in glob.glob(os.path.join(CREDENTIALS_DIRECTORY, "coffer.recipients.*")):
        flags.append(f"--recipients-file={f}")

    subprocess.run(["age", "--encrypt", *flags, "--output", os.path.join(STATE_DIRECTORY, "credentials", name)], stdin=sys.stdin, check=True)


def get(name):
    flags = []

    for f in glob.glob(os.path.join(CREDENTIALS_DIRECTORY, "coffer.identities.*")):
        flags.append(f"--identity={f}")

    subprocess.run(["age", "--decrypt", *flags, os.path.join(STATE_DIRECTORY, "credentials", name)], check=True)


# Check if the peer address is a systemd abstract namespace socket
sock = socket.socket(fileno=sys.stdin.fileno())
try:
    peer = sock.getpeername()
except OSError:
    peer = None
sock.detach()

# systemd peer address format: \0<random>/unit/<unit_name>/<credential_name>
systemd = re.match(rb"^\x00.*/unit/(?P<unit>.+)/(?P<credential>.+)$", peer) if isinstance(peer, bytes) else None

if systemd:
    get(systemd.group("credential").decode())
else:
    # Read the first line byte-by-byte from the raw fd so we don't
    # buffer past the newline — age needs the remaining stdin intact.
    raw = b"".join(iter(lambda: os.read(sys.stdin.fileno(), 1), b"\n"))
    action, name = raw.decode().split(None, 1)

    match action:
        case "POST":
            post(name)
        case "GET":
            get(name)
        case _:
            print(f"unknown action: {action}")


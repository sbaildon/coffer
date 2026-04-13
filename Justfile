listen:
    socat UNIX-LISTEN:$XDG_RUNTIME_DIR/coffer.socket,reuseaddr,fork EXEC:"python3 coffer.py"


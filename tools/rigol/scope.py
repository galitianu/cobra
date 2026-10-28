"""Command-line access to the Rigol over USB, reusing rigol-mcp's connection code.

Use this when the rigol MCP server is not loaded in the session. Run from the project root:

    uv run --project tools/rigol-mcp python tools/rigol/scope.py idn
    uv run --project tools/rigol-mcp python tools/rigol/scope.py shot [name]
    uv run --project tools/rigol-mcp python tools/rigol/scope.py scpi ":MEAS:ITEM? FREQ,CHAN1"
    uv run --project tools/rigol-mcp python tools/rigol/scope.py state
"""
import json
import os
import sys
import time
import warnings
from pathlib import Path

warnings.filterwarnings("ignore")
os.environ.setdefault("RIGOL_USB", "1")

from rigol_mcp import scope as rs  # noqa: E402

PROJECT = Path(__file__).resolve().parents[2]
SHOTS = PROJECT / "captures" / "scope" / "screenshots"


def main() -> None:
    cmd, *args = sys.argv[1:] or ["idn"]
    s = rs.get_scope()
    if cmd == "idn":
        print(rs.idn(s))
    elif cmd == "shot":
        SHOTS.mkdir(parents=True, exist_ok=True)
        name = args[0] if args else "shot"
        path = SHOTS / f"{time.strftime('%Y%m%d-%H%M%S')}_{name}.png"
        path.write_bytes(rs.screenshot_png(s))
        print(path)
    elif cmd == "scpi":
        for c in args:
            print(rs.send_raw(s, c))
    elif cmd == "state":
        print(json.dumps(rs.get_scope_state(s), indent=2, default=str))
    else:
        sys.exit(f"unknown command {cmd}")


if __name__ == "__main__":
    main()

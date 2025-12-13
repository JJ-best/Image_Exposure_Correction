#!/usr/bin/env python3
"""Generate IEEE-754 double-precision encodings for integers 0-255."""
from pathlib import Path
import struct

HEX_PATH = Path(__file__).with_name("int2fp_hex.dat")
FP64_ONLY_PATH = Path(__file__).with_name("int2fp_fp64.dat")


def int_to_fp64_hex(value: int) -> str:
    """Return the IEEE-754 hex encoding of value converted to float64."""
    float_val = float(value)
    packed = struct.pack('>d', float_val)
    return packed.hex()


def main() -> None:
    hex_values = [f"{int_to_fp64_hex(value)} #{value:3d}" for value in range(256)]
    fp_values = [f"{float(value)}" for value in range(256)]
    HEX_PATH.write_text("\n".join(hex_values) + "\n", encoding="ascii")
    FP64_ONLY_PATH.write_text("\n".join(f"{val}" for val in fp_values) + "\n", encoding="ascii")
    print(
        f"Wrote {len(hex_values)} entries to "
        f"{HEX_PATH.name} and {FP64_ONLY_PATH.name}"
    )


if __name__ == "__main__":
    main()

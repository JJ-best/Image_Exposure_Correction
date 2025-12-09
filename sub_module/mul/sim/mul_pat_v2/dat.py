# Author: Jesse
# Generate two sets of floating-point mul patterns using sign/exp/mantissa
# construction similar to p.py (hardware-aligned). Files are named with
# set suffixes (_0, _1) for clarity.
import random
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def bits_to_float(bits):
    return struct.unpack(">d", struct.pack(">Q", bits))[0]


def assemble_float(sign, exponent, mantissa):
    # keep within normal exponent range to avoid inf/NaN
    exponent = min(exponent, 2046)
    mantissa &= (1 << 52) - 1
    bits = (sign << 63) | (exponent << 52) | mantissa
    return bits_to_float(bits)


def generate_random_sign():
    return random.randint(0, 1)


def generate_random_exp():
    return random.randint(512, 512+1023)


def generate_random_mantissa():
    return random.randint(0, (1 << 52) - 1)


def generate_float_list(n):
    floats = []
    for _ in range(n):
        s = generate_random_sign()
        e = generate_random_exp()
        m = generate_random_mantissa()
        floats.append(assemble_float(s, e, m))
    return floats


def write_float_file(path, data):
    path = Path(path)
    with path.open("w") as f:
        for num in data:
            f.write(f"{num:.17e}\n")


def main():
    sample_count = 200
    # Two sets: (num1_0, num2_0) and (num1_1, num2_1)
    num1_0 = generate_float_list(sample_count)
    num2_0 = generate_float_list(sample_count)
    num1_1 = generate_float_list(sample_count)
    num2_1 = generate_float_list(sample_count)

    write_float_file(ROOT / "num1_0.dat", num1_0)
    write_float_file(ROOT / "num2_0.dat", num2_0)
    write_float_file(ROOT / "num1_1.dat", num1_1)
    write_float_file(ROOT / "num2_1.dat", num2_1)

    print(f"Wrote set0 to {ROOT/'num1_0.dat'} and {ROOT/'num2_0.dat'}")
    print(f"Wrote set1 to {ROOT/'num1_1.dat'} and {ROOT/'num2_1.dat'}")


if __name__ == "__main__":
    main()

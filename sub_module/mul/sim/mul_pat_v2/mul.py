# Author: Jesse
# Use the same fp64_mul logic as p.py (hardware-aligned) to generate floating-point mul patterns.
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def bits_to_float(b):
    return struct.unpack(">d", struct.pack(">Q", b))[0]


def float_to_uint64(x):
    return struct.unpack(">Q", struct.pack(">d", x))[0]


def encode_IEEE754(s, e, m):
    m_funct = m & ((1 << 52) - 1)
    bits = (s << 63) | (e << 52) | m_funct
    return bits


def round_to_nearest_even_with_sticky(m, lsb_position=52):
    m_funct = m
    guard = (m_funct >> (lsb_position - 1)) & 1
    round_bit = (m_funct >> (lsb_position - 2)) & 1

    sticky_mask = (1 << (lsb_position - 2)) - 1
    sticky = (m_funct & sticky_mask) != 0
    lsb = (m_funct >> (lsb_position)) & 1
    if guard and (round_bit or sticky or lsb):
        m_funct += 1 << (lsb_position)
    return m_funct >> (lsb_position)


def normalize(m, e, position_move):
    m_funct = m
    e_funct = e
    if m_funct == 0:
        return 0, 0
    while m_funct >= (1 << (53 + position_move)):
        m_funct >>= 1
        e_funct += 1
    while m_funct and (m_funct < (1 << (52 + position_move))):
        if e_funct == 0:
            return m_funct, e_funct
        else:
            m_funct <<= 1
            e_funct -= 1
    return m_funct, e_funct


def fp64_mul(ma, mb, ea, eb, sa, sb):
    # NaN case
    if ea == 2047 and ((ma & ((1 << 52) - 1)) != 0):
        return 0, 2047, 1
    if eb == 2047 and ((mb & ((1 << 52) - 1)) != 0):
        return 0, 2047, 1
    # zero case
    if ma == 0 and ea == 0:
        return 0, 0, 0
    if mb == 0 and eb == 0:
        return 0, 0, 0
    # inf case
    if ea == 2047 and ((ma & ((1 << 52) - 1)) == 0):
        return sa ^ sb, 2047, 0
    if eb == 2047 and ((mb & ((1 << 52) - 1)) == 0):
        return sa ^ sb, 2047, 0

    result_m = ma * mb
    result_s = 0 if sa == sb else 1
    mul_e = ea + eb - 1023

    result_m, result_e = normalize(result_m, mul_e, position_move=52)
    result_m = round_to_nearest_even_with_sticky(result_m, lsb_position=52)
    result_m_final, result_e_final = normalize(result_m, result_e, position_move=0)
    if result_e_final >= 2047:
        return result_s, 2047, 0
    elif result_e_final < 0:
        return 0, 0, 0
    elif result_e_final == 0 and result_m_final == 0:
        return 0, 0, 0
    else:
        return result_s, result_e_final, result_m_final


def extract_components(bits):
    sign_funct = (bits >> 63) & 1
    exponent_funct = (bits >> 52) & 0x7FF
    mantissa_funct = bits & ((1 << 52) - 1)
    if exponent_funct != 0:
        mantissa_funct |= 1 << 52  # hidden bit
    return sign_funct, exponent_funct, mantissa_funct


def read_input_file(path):
    path = Path(path)
    with path.open("r") as f:
        return [float(line.strip()) for line in f]


def write_single_float(path, values):
    path = Path(path)
    with path.open("w") as f:
        for value in values:
            f.write(f"{value:.17e}\n")


def write_hex_from_bits(path, bit_values):
    path = Path(path)
    with path.open("w") as f:
        for bits in bit_values:
            f.write(f"{bits:016X}\n")


def write_hex_file(path, values):
    # convenience for dumping raw float inputs
    write_hex_from_bits(path, (float_to_uint64(v) for v in values))


def mul_with_fp64(num_a, num_b):
    """Use p.fp64_mul to compute results from float lists."""
    results_bits = []
    results_float = []
    for a, b in zip(num_a, num_b):
        a_bits = float_to_uint64(a)
        b_bits = float_to_uint64(b)
        sa, ea, ma = extract_components(a_bits)
        sb, eb, mb = extract_components(b_bits)
        s_res, e_res, m_res = fp64_mul(ma, mb, ea, eb, sa, sb)
        res_bits = encode_IEEE754(s_res, e_res, m_res)
        res_float = bits_to_float(res_bits)
        results_bits.append(res_bits)
        results_float.append(res_float)
    return results_bits, results_float


def main():
    # Two sets of patterns: (num1,num2) and (num3,num4)
    set_specs = [
        ("num1_0.dat", "num2_0.dat", "0"),
        ("num1_1.dat", "num2_1.dat", "1"),
    ]

    for idx, (a_file, b_file, suffix) in enumerate(set_specs):
        num_a = read_input_file(ROOT / a_file)
        num_b = read_input_file(ROOT / b_file)
        assert len(num_a) == len(num_b), f"{a_file} and {b_file} length mismatch"

        results_bits, results_float = mul_with_fp64(num_a, num_b)

        # hex dumps of inputs
        write_hex_file(ROOT / f"num1_hex_{suffix}.dat", num_a)
        write_hex_file(ROOT / f"num2_hex_{suffix}.dat", num_b)
        # golden only keeps results
        write_hex_from_bits(ROOT / f"golden_{suffix}.dat", results_bits)
        write_single_float(ROOT / f"golden_float_{suffix}.dat", results_float)

        print(
            f"Set {suffix}: wrote {len(results_bits)} result hex values to {ROOT / f'golden_{suffix}.dat'}"
        )
        print(
            f"Set {suffix}: wrote float results to {ROOT / f'golden_float_{suffix}.dat'}"
        )
        print(
            f"Set {suffix}: wrote input hex dumps to {ROOT / f'num1_hex_{suffix}.dat'} and {ROOT / f'num2_hex_{suffix}.dat'}"
        )


if __name__ == "__main__":
    main()

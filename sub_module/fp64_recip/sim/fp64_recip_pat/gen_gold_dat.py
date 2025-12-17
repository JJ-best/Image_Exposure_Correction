import random
import struct
import math

TOTAL_CASES = 2000 
FILENAME = "golden.dat"

# ==========================================
# 1. Helper Functions (Float <-> Bits)
# ==========================================
def float_to_bits(f):
    """Convert Python float to 64-bit integer (IEEE 754 representation)"""
    s = struct.pack('>d', f)
    return struct.unpack('>Q', s)[0]

def bits_to_float(b):
    """Convert 64-bit integer to Python float"""
    s = struct.pack('>Q', b)
    return struct.unpack('>d', s)[0]

# ==========================================
# 2. Main Program
# ==========================================
def generate_standard_fp64_golden():
    cases = []
    
    print("Generating " + FILENAME + " (Using standard software FP64 operations)...")

    # --- A. Corner Cases ---
    corners = [
        1.0, 
        2.0,
        0.5,
        1.5, 
        1.9999999999999998, # Max in [1, 2)
        1.0000000000000002, # Min in (1, 2]
        1.4142135623730951, # sqrt(2)
        1.0 + 1.0/128.0, 
        3.141592653589793,  # Pi
        float('inf'),       # Infinity
        float('-inf'),      # -Infinity
        0.0,                # +0.0
        -0.0,               # -0.0
        float('nan')        # NaN
    ]
    cases.extend(corners)

    # --- B. Special Patterns (Mantissa Testing) ---
    # Testing specific mantissa patterns for exponent 1023 (Values between 1.0 and 2.0)
    patterns = [0xFFFFFFFFFFFFF, 0xAAAAAAAAAAAAA, 0x5555555555555, 0x0000000000001]
    for pat in patterns:
        cases.append(bits_to_float((1023 << 52) | pat))

    # --- C. Random Filling (Random Cases) ---
    # Ensure coverage of various Exponent ranges (Denormal ~ Normal ~ Large)
    for _ in range(TOTAL_CASES - len(cases)):
        # Random Mantissa (1.0 ~ 2.0)
        mant = random.uniform(1.0, 2.0)
        # Random Exponent (-1000 ~ +1000)
        exp = random.randint(-1000, 1000)
        val = mant * (2.0 ** exp)
        
        # Random Sign
        if random.random() > 0.5: 
            val = -val
            
        cases.append(val)

    # --- Write to File ---
    with open(FILENAME, 'w') as f:
        # Header for readability
        f.write("// Format: {Input_Hex_64}{Expected_Hex_64} // In=... Exp=...\n")
        
        for input_val in cases:
            # 1. Get Input Hex
            input_hex = float_to_bits(input_val)

            # 2. Calculate Standard Golden Result
            try:
                # Handle NaN
                if math.isnan(input_val):
                    expected_val = float('nan')
                # Handle 0 (1/0 = Inf)
                elif input_val == 0.0:
                    # copysign ensures correct sign handling (+0 -> +inf, -0 -> -inf)
                    expected_val = math.copysign(float('inf'), input_val)
                # Handle Inf (1/Inf = 0)
                elif math.isinf(input_val):
                    expected_val = math.copysign(0.0, input_val)
                # Normal Case
                else:
                    expected_val = 1.0 / input_val
            except ZeroDivisionError:
                # Safety catch for zero division, treating as Inf
                expected_val = math.copysign(float('inf'), input_val)

            # 3. Get Output Hex
            expected_hex = float_to_bits(expected_val)

            # 4. Format Output
            # Combine two 64-bit hex strings into one 128-bit line for easier Verilog $readmemh reading
            # Verilog Testbench: input_data = line[127:64], golden_data = line[63:0]
            hex_part = "{:016X}{:016X}".format(input_hex, expected_hex)
            
            # 5. Comment Section (For Debugging)
            # Use .format() for compatibility with older Python versions
            comment_part = "// In={:<25.17g} Expect={:<25.17g}".format(input_val, expected_val)
            
            f.write("{}  {}\n".format(hex_part, comment_part))

    print("OK! File " + FILENAME + " generated.")
    print("-" * 60)
    print("Example Output (First 3 lines):")
    with open(FILENAME, 'r') as f:
        print(f.readline().strip())
        print(f.readline().strip())
        print(f.readline().strip())

if __name__ == "__main__":
    generate_standard_fp64_golden()
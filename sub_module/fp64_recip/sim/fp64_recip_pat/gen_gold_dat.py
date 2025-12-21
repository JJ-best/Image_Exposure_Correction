import random
import struct
import math


TOTAL_CASES = 3000 
FILENAME = "golden.dat"

# IEEE 754 Double Precision Constants
MIN_NORMAL_POS_DOUBLE = 2.2250738585072014e-308
MAX_NORMAL_POS_DOUBLE = 1.7976931348623157e+308

# ==========================================
# 1. Helper Functions (Float <-> Bits)
# ==========================================
def float_to_bits(f):
    """Convert Python float to 64-bit integer (IEEE 754 representation)"""
    # packing to double
    s = struct.pack('>d', f)
    # unpacking as unsigned long long (64-bit)
    return struct.unpack('>Q', s)[0]

def bits_to_float(b):
    """Convert 64-bit integer to Python float"""
    s = struct.pack('>Q', b)
    return struct.unpack('>d', s)[0]

# ==========================================
# 2. Main Program
# ==========================================
def generate_fp64_recip_golden():
    cases = []
    
    print("Generating " + FILENAME + " ...")
    print("Logic 1: Input Denormal -> Output Max Normal (Exp=2046)")
    print("Logic 2: Output Denormal -> Flush to Zero (FTZ)")

    # ---------------------------------------------------------
    # A. Standard Corner Cases
    # ---------------------------------------------------------
    corners = [
        1.0, 2.0, 0.5, 1.5, 
        1.9999999999999998, # Max in [1, 2)
        1.0000000000000002, # Min in (1, 2]
        1.4142135623730951, # sqrt(2)
        3.141592653589793,  # Pi
        float('inf'),       # Infinity
        float('-inf'),      # -Infinity
        0.0,                # +0.0
        -0.0,               # -0.0
        float('nan')        # NaN
    ]
    cases.extend(corners)

    # ---------------------------------------------------------
    # B. Special Mantissa Patterns (for Exp=1023)
    # ---------------------------------------------------------
    patterns = [0xFFFFFFFFFFFFF, 0xAAAAAAAAAAAAA, 0x5555555555555, 0x0000000000001]
    for pat in patterns:
        cases.append(bits_to_float((1023 << 52) | pat))

    # ---------------------------------------------------------
    # C. Input Denormals (Testing Input Logic)
    # ---------------------------------------------------------
    denorm_inputs = []
    # Min Positive Denorm
    denorm_inputs.append(bits_to_float(0x0000000000000001)) 
    # Max Positive Denorm
    denorm_inputs.append(bits_to_float(0x000FFFFFFFFFFFFF)) 
    # Min Negative Denorm
    denorm_inputs.append(bits_to_float(0x8000000000000001)) 
    # Max Negative Denorm
    denorm_inputs.append(bits_to_float(0x800FFFFFFFFFFFFF)) 
    
    # Random Denormals
    for _ in range(50):
        frac = random.getrandbits(52)
        if frac == 0: frac = 1 # frac=0 is Zero, not Denorm
        sign_bit = (1 if random.random() > 0.5 else 0) << 63
        val_bits = sign_bit | frac # Exp is 0
        denorm_inputs.append(bits_to_float(val_bits))

    cases.extend(denorm_inputs)

    # ---------------------------------------------------------
    # D. Large Inputs (Testing Output FTZ Logic)
    # ---------------------------------------------------------
    # Inputs that create very small results (Underflow)
    underflow_inputs = []
    # Max Normal Input -> Result ~ 5.56e-309 (Denormal) -> Should be 0
    underflow_inputs.append(bits_to_float(0x7FEFFFFFFFFFFFFF)) 
    underflow_inputs.append(bits_to_float(0x7FF0000000000000 - 1))
    
    for _ in range(100):
        # Biased Exp 2045~2046 (Large numbers)
        exp = random.choice([2045, 2046]) 
        frac = random.getrandbits(52)
        sign_bit = (1 if random.random() > 0.5 else 0) << 63
        val_bits = sign_bit | (exp << 52) | frac
        underflow_inputs.append(bits_to_float(val_bits))
        
    cases.extend(underflow_inputs)

    # ---------------------------------------------------------
    # E. Random Filling
    # ---------------------------------------------------------
    remaining = TOTAL_CASES - len(cases)
    for _ in range(remaining):
        # Range 1 ~ 2046 (Normal numbers)
        bi_exp = random.randint(1, 2046)
        frac = random.getrandbits(52)
        sign = random.randint(0, 1)
        bits = (sign << 63) | (bi_exp << 52) | frac
        cases.append(bits_to_float(bits))

    # ---------------------------------------------------------
    # Write to File
    # ---------------------------------------------------------
    with open(FILENAME, 'w') as f:
        f.write("// Format: {Input_Hex_64}{Expected_Hex_64} // Comment\n")
        
        for input_val in cases:
            input_hex = float_to_bits(input_val)
            
            # Extract input fields
            in_sign = (input_hex >> 63) & 0x1
            in_exp  = (input_hex >> 52) & 0x7FF
            in_mant = input_hex & 0xFFFFFFFFFFFFF

            # --- Logic Decision Tree ---
            
            # 1. Input is Denormal (Exp=0, Mant!=0)
            if in_exp == 0 and in_mant != 0:
                # Custom Logic: Output Max Normal
                if in_sign == 0:
                    expected_hex = 0x7FEFFFFFFFFFFFFF # +Max Normal
                else:
                    expected_hex = 0xFFEFFFFFFFFFFFFF # -Max Normal
                
                expected_val = bits_to_float(expected_hex)
                note = "[Custom: Input Denorm -> Max Normal]"

            # 2. Input is Zero
            elif input_val == 0.0:
                expected_val = math.copysign(float('inf'), input_val)
                expected_hex = float_to_bits(expected_val)
                note = "[Zero -> Inf]"

            # 3. Input is NaN
            elif math.isnan(input_val):
                expected_val = float('nan')
                expected_hex = float_to_bits(expected_val)
                note = "[NaN]"
                
            # 4. Input is Infinity
            elif math.isinf(input_val):
                expected_val = math.copysign(0.0, input_val)
                expected_hex = float_to_bits(expected_val)
                note = "[Inf -> Zero]"

            # 5. Normal Calculation
            else:
                try:
                    expected_val = 1.0 / input_val
                    
                    # --- Output FTZ Check ---
                    # Check if result is Denormal (non-zero but smaller than Min Normal)
                    if expected_val != 0.0 and abs(expected_val) < MIN_NORMAL_POS_DOUBLE:
                        # Flush to Zero
                        expected_val = math.copysign(0.0, expected_val)
                        note = "[Output FTZ Applied]"
                    else:
                        note = ""
                        
                    expected_hex = float_to_bits(expected_val)
                    
                except ZeroDivisionError:
                    expected_val = math.copysign(float('inf'), input_val)
                    expected_hex = float_to_bits(expected_val)
                    note = "[DivByZero]"

            # Write line using classic formatting
            hex_part = "{:016X}{:016X}".format(input_hex, expected_hex)
            comment_part = "// In={:<15.6g} Out={:<15.6g} {}".format(input_val, expected_val, note)
            
            f.write("{}  {}\n".format(hex_part, comment_part))

    print("OK! File {} generated with {} patterns.".format(FILENAME, len(cases)))

if __name__ == "__main__":
    generate_fp64_recip_golden()
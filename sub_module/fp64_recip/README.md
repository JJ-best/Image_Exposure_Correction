# Floating Point 64 Reciprocal

## 1. IEEE754 Format

IEEE754 format is 64-bit, used to represent a floating point number.

| Field               | Width   | Description                                    |
| ------------------- | ------- | ---------------------------------------------- |
| sign                | 1 bit   | Number sign                                    |
| exponent            | 11 bits | Biased exponent                                |
| mantissa (fraction) | 52 bits | Fraction bits (without the implicit leading 1) |


## 2. Value Categories

`fp64_recip` supports all IEEE 754 FP64 categories:

### 2.1 Normalized Numbers

- Condition: `0 < exponent < 2047`
- Value:
  $
  x = (-1)^S \times (1.mantissa)_2 \times 2^{exponent - 1023}
  $

### 2.2 Denormalized (Subnormal) Numbers

- Condition: `exponent = 0` and `mantissa != 0`
- Value:
  $
  x = (-1)^S \times (0.mantissa)_2 \times 2^{-1022}
  $
- There is no implicit leading `1` for subnormals.
- The power of 2 is constant = -1022

### 2.3 Zero

- `+0`: `sign = 0`, `exponent = 0`, `mantissa = 0`
- `-0`: `sign = 1`, `exponent = 0`, `mantissa = 0`

### 2.4 Infinity

- Condition: `exponent = 2047` and `mantissa = 0`
- Represents `+∞` or `-∞`.

### 2.5 NaN (Not a Number)

- Condition: `exponent = 2047` and `mantissa != 0`
- `fp64_recip` propagates NaN inputs to NaN outputs.

## 3. Module IO
```verilog
module fp64_reciprocal #(
    parameter pFP_WIDTH = 64
)(
    input clk,
    input srst_n,
    input [(pFP_WIDTH-1):0] in_A    // write input data in tb
    input in_valid,                 // pull-up input valid in tb
    output [(pFP_WIDTH-1):0] in_B,  // recip of input date
    output output_valid             // pull up output valid when data the valid
);
// please make sure that the period can be faster than 3ns

endmodule //fp64_recip
```

## 4. Function
Input an fp64 number output the corresponding ieee754 1/fp64 number.

For example, the input 1.33212 with ieee754 format is `64'h3faa82e8`. 

The reciprocal is 1/1.33212 = 0.75068312, the output with ieee754 format is `64'h3f402cc5`.

Please generate the test pattern with py. 

And write tb(You may use the system function `$bitstoreal()` in the rtl-tb to translate you fp64 output). A little round error may be available.

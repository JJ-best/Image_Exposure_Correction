import math

def generate_verilog_lut():
    print("// Goldschmidt 7-bit LUT - Generated for 20-Hour Project")
    print("// Maps Divisor Mantissa addr, output reg [7:0] data);")
    print("always @(*) begin")
    print("    case(addr)")
    
    for i in range(128):
        val = 1.0 + (i + 0.5)/128.0
        reciprocal = 1.0 / val
        
        quantized = int(round(reciprocal * 256))
        
        if quantized > 255: quantized = 255
        
        print(f"        7'd{i}: data = 8'h{quantized:02X}; // D~={val:.4f}, 1/D~={reciprocal:.4f}")
        
    print("        default: data = 8'hFF;")
    print("    endcase")
    print("end")
    print("endmodule")

if __name__ == "__main__":
    generate_verilog_lut()
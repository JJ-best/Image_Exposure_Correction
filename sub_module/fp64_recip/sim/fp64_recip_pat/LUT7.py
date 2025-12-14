import math

def generate_verilog_lut():
    print("// Goldschmidt 7-bit LUT - Generated for 20-Hour Project")
    print("// Maps Divisor Mantissa addr, output reg [7:0] data);")
    print("always @(*) begin")
    print("    case(addr)")
    
    for i in range(128):
        # 7 bits 代表在 /128 的小數部分偏移
        # 完整的尾數範圍是 [1.0, 2.0)
        # 我們將其表示為 8 bits。
        # 由於值總是 < 1.0，MSB 權重為 2^-1 (0.5)
        # value = data / 256
        
        # 建立一個測試值，加上 0.5/128 是為了取區間中間值以減少誤差
        val = 1.0 + (i + 0.5)/128.0
        reciprocal = 1.0 / val
        
        quantized = int(round(reciprocal * 256))
        
        # 鉗制到 8 bits (雖然 1.0 嚴格需要 9 bits, 
        # 但 1/1.0 是一個通常由飽和或特殊邏輯處理的邊角案例)
        if quantized > 255: quantized = 255
        
        print(f"        7'd{i}: data = 8'h{quantized:02X}; // D~={val:.4f}, 1/D~={reciprocal:.4f}")
        
    print("        default: data = 8'hFF;")
    print("    endcase")
    print("end")
    print("endmodule")

if __name__ == "__main__":
    generate_verilog_lut()
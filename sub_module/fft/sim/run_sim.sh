#!/bin/bash

# Always generate VCD first, then convert to FST
WAVEFORM_FORMAT=0

echo "=========================================="
echo "Running FFT Simulation"
echo "Step 1: Generating VCD waveform..."
echo "=========================================="

vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs.log \
    +define+MODE=1 +define+COL_STAGE=6 +define+WAVEFORM_FORMAT=$WAVEFORM_FORMAT

# Check VCD file generation
if [ -f "fft_sim.vcd" ]; then
    echo ""
    echo "=========================================="
    echo "VCD waveform file generated successfully!"
    echo "=========================================="
    echo ""
    echo "File: fft_sim.vcd"
    echo "Size: $(du -h fft_sim.vcd | cut -f1)"
    echo ""
    
    # Convert VCD to FST
    echo "=========================================="
    echo "Step 2: Converting VCD to FST format..."
    echo "=========================================="
    
    if command -v vcd2fst &> /dev/null; then
        vcd2fst fft_sim.vcd fft_sim.fst
        
        if [ -f "fft_sim.fst" ]; then
            echo ""
            echo "=========================================="
            echo "FST waveform file generated successfully!"
            echo "=========================================="
            echo ""
            echo "VCD file: fft_sim.vcd"
            echo "VCD size: $(du -h fft_sim.vcd | cut -f1)"
            echo ""
            echo "FST file: fft_sim.fst"
            echo "FST size: $(du -h fft_sim.fst | cut -f1)"
            echo ""
            echo "To view in GTKWave:"
            echo "  gtkwave fft_sim.fst"
            echo ""
        else
            echo "Warning: Failed to convert VCD to FST"
            echo "VCD file is still available: fft_sim.vcd"
        fi
    else
        echo "Warning: vcd2fst command not found"
        echo "VCD file is available: fft_sim.vcd"
        echo ""
        echo "To convert manually:"
        echo "  vcd2fst fft_sim.vcd fft_sim.fst"
        echo ""
    fi
else
    echo "Error: fft_sim.vcd not found - simulation may have failed"
    exit 1
fi


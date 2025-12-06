# Image_Exposure_Correction
A hardware implementation of illumination-map-based image enhancement, featuring LIME estimation, dual illumination correction (forward + inverted images), and multi-exposure fusion for robust under/over-exposure correction.

## Test Pattern
run main.py

The test pattern is in the following file list, verilog testbench will reading these bmp file to generate golden data.

Each golden data is 32x32x3 bmp dile.
```
imgs_lime1
..\input_image
..\initial_illum_map
..\refined_illum_map
..\gamma_illum_map
..\enhanced_image
imgs_lime2
..\input_image
..\initial_illum_map
..\refined_illum_map
..\gamma_illum_map
..\enhanced_image
```

## Testbench
```
* note: Loop idx depend on the patch number = 28(0-27, 0-27)
Loop i{ 
    Loop j{
        1. read input image patch into sram_A
        (3126 byte = 54 byte(head) + 3072 byte(data))
        Reference the HW4 sram task
        2. The golden data may be(depends on the tcl), 
        the golden should also only capture l3072 data
        byte from bmp
        {
        * note: here may have 50 iteration(correspond), 
        to lime.py, but I think we can do only one 
        iteration now, just for first round check.
        - initial_illum_map
        - refined_illum_map
        - gamma_illum_map
        - enhanced_image
        }
        - ...image fusion, comming soon
    }
}
```

## Memory Allocate

### SRAM A
Used to store a patch of input image(32x32 pixel, each pixel have (R,G,B), range from (0,255) 8-bit), so the sram size is 32x32x24-bit = 3072-byte(discard the 54-byte head).

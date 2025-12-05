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
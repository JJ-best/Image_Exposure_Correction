from PIL import Image
from pathlib import Path
import os
import struct

root = Path(__file__).resolve().parent
img_path = root / "imgs_lime1" / "input_image" / "patch_0_20_under.bmp"

# -------------------------------
# 1. read image information
# -------------------------------
with Image.open(img_path) as img:
    width, height = img.size
    mode = img.mode
    offset_pil = img.fp.tell()

# -------------------------------
# 2. read offset with binary
# -------------------------------
with open(img_path, "rb") as f:
    f.seek(10)
    offset_bin = struct.unpack("<I", f.read(4))[0]

# -------------------------------
# 3. display bmp file size
# -------------------------------
file_size = os.path.getsize(img_path)

# -------------------------------
# 4. calculate byte per pixel
# -------------------------------
if mode == "RGB":
    bpp = 3
elif mode == "L":       # gray
    bpp = 1
elif mode == "RGBA":
    bpp = 4
else:
    raise ValueError(f"Unsupported mode: {mode}")

# -------------------------------
# 5. expect bmp data byte
# -------------------------------
expected_pixel_bytes = width * height * bpp

# -------------------------------
# 6. actual bmp data size
# -------------------------------
actual_pixel_bytes = file_size - offset_pil

# -------------------------------
# print bmp file check
# -------------------------------
print("========= BMP FILE CHECK =========")
print("Image path        =", img_path)
print("Image size        =", (width, height))
print("Image mode        =", mode)
print("Bytes per pixel   =", bpp)
print("----------------------------------")
print("File size         =", file_size, "bytes")
print("Header offset PIL =", offset_pil, "bytes")
print("Header offset BIN =", offset_bin, "bytes")
print("----------------------------------")
print("Expected pixel bytes =", expected_pixel_bytes)
print("Actual pixel bytes   =", actual_pixel_bytes)
print("----------------------------------")

if expected_pixel_bytes == actual_pixel_bytes:
    print("✅ Pixel data size matches exactly!")
else:
    print("❌ Pixel data size MISMATCH!")

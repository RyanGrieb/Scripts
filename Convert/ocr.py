import os
import sys
import img2pdf
import ocrmypdf
from pdf2image import convert_from_path
from io import BytesIO

# Prerequisites:
# sudo apt install poppler-utils tesseract-ocr
# pip install ocrmypdf pdf2image img2pdf


def make_pdf_searchable(input_path):
    root, ext = os.path.splitext(input_path)
    output_path = f"{root}-ocr{ext}"
    temp_pdf_path = f"{root}_temp_flattened.pdf"

    print(f"Processing: {input_path}")
    print("Step 1: Rasterizing pages to remove existing text layers...")

    try:
        # 1. Convert PDF pages to high-quality images (300 DPI)
        # This converts the text/vectors into flat pixels, removing the "un-copyable" layer.
        images = convert_from_path(input_path, dpi=300, fmt="jpeg")

        # 2. Convert those images back into a temporary PDF
        image_bytes_list = []
        for img in images:
            img_buffer = BytesIO()
            img.save(img_buffer, format="JPEG", quality=95)
            image_bytes_list.append(img_buffer.getvalue())

        with open(temp_pdf_path, "wb") as f:
            f.write(img2pdf.convert(image_bytes_list))

    except Exception as e:
        print(f"Error during rasterization step: {e}")
        return

    print("Step 2: Running OCR on the clean document...")

    try:
        # 3. Run OCR on the temporary flat PDF
        ocrmypdf.ocr(
            temp_pdf_path,
            output_path,
            deskew=False,  # Not needed for digital rasterization
            force_ocr=True,  # Required because the temp file is just images
            clean=True,  # cleans up digital noise
            optimize=1,  # compression to keep file size reasonable
        )
        print(f"Success! Saved to: {output_path}")

    except Exception as e:
        print(f"OCR failed: {e}")

    finally:
        # 4. Clean up the temporary file
        if os.path.exists(temp_pdf_path):
            os.remove(temp_pdf_path)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 ocr_script.py <input_pdf>")
    else:
        make_pdf_searchable(sys.argv[1])

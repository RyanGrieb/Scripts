# File Conversion Utilities

A collection of Python utility scripts for converting and manipulating document formats (PDF, DOCX, etc.).

## 📜 Scripts

### 1. PDF to DOCX Converter (`convert_pdf2docx.py`)

Converts PDF documents into editable Microsoft Word (`.docx`) files.

- **Key Features:** Preserves layout (tables/images) and automatically names the output file.
- **Usage:**
  ```bash
  python3 convert_pdf2docx.py input_file.pdf
  ```
  _Output: `input_file.docx`_

### 2. OCR / Searchable PDF Generator (`ocr.py`)

Force-flattens a PDF into images and runs OCR (Optical Character Recognition) on it to create a fresh, searchable text layer.

- **Use Case:** Best for fixing PDFs where the text cannot be copied/highlighted correctly, or for digitizing scanned documents.
- **Key Features:** Rasterizes pages to remove corrupt text layers, applies Tesseract OCR, and optimizes the final file size.
- **Usage:**
  ```bash
  python3 ocr.py input_file.pdf
  ```
  _Output: `input_file-ocr.pdf`_

---

## 🛠 Installation & Requirements

### System Requirements (Linux/Debian/Ubuntu)

The OCR script relies on system-level tools for image processing and text recognition.

```bash
sudo apt update
sudo apt install poppler-utils tesseract-ocr
```

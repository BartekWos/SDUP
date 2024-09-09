# SDUP

FFT Top Module for Xilinx/AMD IP Core (16-Point, 16-bit Complex Input)

Overview
--------
This repository contains a top-level module for performing Fast Fourier Transform (FFT) using Xilinx/AMD's IP core, customized specifically for a transformation length of 16 and complex input data represented as 16-bit fixed-point numbers (QI format). Alongside the module, this repository includes a testbench and a Python notebook for data handling and verification.


Features
--------
- FFT Top Module:
  - Configured for a 16-point FFT.
  - Accepts 16-bit complex input data (QI format)

- Testbench:
  - Loads input data in hexadecimal format generated from a Python notebook.
  - Simulates the FFT and AXI stream operation and saves the output data to a text file.
 
- Python Notebook:
  - Generates complex sine wave in hex format for the testbench.
  - Converts hexadecimal FFT HDL output data back to complex numbers.
  - Compares the python reference FFT with HDL implementation

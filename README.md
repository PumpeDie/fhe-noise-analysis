# FHE Noise Analysis (LWE)

Proof of Concept (PoC) evaluating the empirical noise growth in Fully Homomorphic Encryption (FHE) systems based on the Learning With Errors (LWE) problem. 

## Context

Homomorphic encryption allows computations directly on ciphertexts. However, operations (especially multiplications) consume a "noise budget". This project implements the BFV scheme using **Microsoft SEAL** to monitor and analyze the depletion of this noise budget before ciphertext corruption occurs.

This project implements the BFV scheme using [Microsoft SEAL](https://github.com/microsoft/SEAL) to monitor and analyze the depletion of this noise budget before ciphertext corruption occurs (the "cliff effect"). It uses image processing to visually demonstrate the concepts:

- Addition (Brightness): Consumes negligible noise.
- Polynomial Evaluation (Gamma Correction): Requires consecutive ciphertext multiplications, consuming massive amounts of noise budget.

The architecture is split into a Client/Server visualization via a web interface, proving the server operates blindly on encrypted data.

## Run Instructions

Prerequisites:

- C++ Compiler (GCC/Clang/MSVC)
- CMake (>= 3.14)
- Python 3.x
- [uv](https://docs.astral.sh/uv/) (optional, you can install `flask` and `pillow`)

This project uses CMake `FetchContent` to download and build Microsoft SEAL automatically. No system-wide installation is required.

```bash
# 1. Generate the build environment
cmake -B build

# 2. Compile the project (SEAL will be fetched and built statically)
cmake --build build

# 3. Start the web server
uv run server.py

# Or `python -m venv .venv && source .venv/bin/activate && pip install flask pillow && python server.py`
```

Open a web browser and navigate to: <http://127.0.0.1:5000>

---

Developed as part of the Cryptography (8INF874) course at UQAC.

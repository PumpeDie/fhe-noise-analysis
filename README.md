# FHE Noise Analysis (LWE)

Proof of Concept (PoC) evaluating the empirical noise growth in Fully Homomorphic Encryption (FHE) systems based on the Learning With Errors (LWE) problem. 

## Context
Homomorphic encryption allows computations directly on ciphertexts. However, operations (especially multiplications) consume a "noise budget". This project implements the BFV scheme using **Microsoft SEAL** to monitor and analyze the depletion of this noise budget before ciphertext corruption occurs.

## Build Instructions

This project uses CMake `FetchContent` to download and build Microsoft SEAL automatically. No system-wide installation is required.

```bash
# 1. Generate the build environment
cmake -B build

# 2. Compile the project (SEAL will be fetched and built statically)
cmake --build build

# 3. Run the executable
./build/fhe-noise-analysis
```

---

Developed as part of the Cryptography (8INF874) course at UQAC.
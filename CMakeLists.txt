cmake_minimum_required(VERSION 3.14)
project(fhe-noise-analysis VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Required for LSP autocompletion
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ---- DEPENDENCY ISOLATION ----
include(FetchContent)
FetchContent_Declare(
    SEAL
    GIT_REPOSITORY https://github.com/microsoft/SEAL.git
    GIT_TAG        v4.3.2
)

# Disable unnecessary SEAL options to speed up compilation
set(SEAL_BUILD_EXAMPLES OFF CACHE BOOL "Build examples" FORCE)
set(SEAL_BUILD_TESTS OFF CACHE BOOL "Build tests" FORCE)
set(SEAL_USE_ZLIB OFF CACHE BOOL "Use ZLIB" FORCE)
set(SEAL_USE_ZSTD OFF CACHE BOOL "Use ZSTD" FORCE)

FetchContent_MakeAvailable(SEAL)
# ------------------------------------

# Executable
add_executable(fhe-noise-analysis src/main.cpp)

# Link against the local SEAL target
target_link_libraries(fhe-noise-analysis PRIVATE SEAL::seal)
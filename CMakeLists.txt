cmake_minimum_required(VERSION 3.14)
project(ProjetFHE_FiltreImage)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SEAL_USE_ZLIB OFF CACHE BOOL "Disable ZLIB" FORCE)
set(SEAL_USE_ZSTD OFF CACHE BOOL "Disable ZSTD" FORCE)
set(SEAL_USE_MSGSL OFF CACHE BOOL "Disable MSGSL" FORCE)

include(FetchContent)

# Dépendance : Microsoft SEAL
FetchContent_Declare(
    SEAL
    GIT_REPOSITORY https://github.com/microsoft/SEAL.git
    GIT_TAG        v4.3.2
)
FetchContent_MakeAvailable(SEAL)

# Dépendance : stb
FetchContent_Declare(
    stb
    GIT_REPOSITORY https://github.com/nothings/stb.git
    GIT_TAG        master
)
FetchContent_MakeAvailable(stb)

add_executable(main src/main.cpp src/stb_impl.cpp)

target_link_libraries(main PRIVATE SEAL::seal)
target_include_directories(main PRIVATE ${stb_SOURCE_DIR})

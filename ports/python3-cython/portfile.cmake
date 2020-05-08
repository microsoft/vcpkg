vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cython/cython
    REF 0.28.1
    SHA512 3346ebe01049ff6628f74ee1904d440680ccc7fc09c51afd26d6e05264318678c9fb64da4d98703d3e687662e98125e0b182d01cb9276cbb4fcb014ecb35be63 
    HEAD_REF master
)

vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})

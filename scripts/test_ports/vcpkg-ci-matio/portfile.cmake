set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio-eigen-example
    REF 5bbc27b18d544dcbdd7bfb821e4ef843301d4a95
    SHA512 c74ef6ee94a1c2723bef4868a36894b6431acd5806386284a4be3c5a43c573edcb2d477bc23031f56f5110e231b1ff2d5aa227e79845f1b7a7b50909a905c303
    HEAD_REF master
    PATCHES
        vcpkg.diff
)

vcpkg_download_distfile(EIGEN_MATIO_HEADER
    URLS "https://github.com/tbeu/eigen-matio/raw/b29e109083b9836471565f8d06f44a76a11d0def/MATio"
    FILENAME "tbeu/matio-eigen-MATio-b29e109"
    SHA512 06c7fe74a8e91d08dba6ff804ee0c925130d9280c916cf8d4c739f4c7dbf421cb00225783fa22e1e02bac03c49ed024dcc35fef0d8edeec7a724ce3406f3fbf1
)
file(COPY_FILE "${EIGEN_MATIO_HEADER}" "${SOURCE_PATH}/include/MATio")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DEIGEN_MATIO_DIR=${SOURCE_PATH}/include"
)
vcpkg_cmake_build()

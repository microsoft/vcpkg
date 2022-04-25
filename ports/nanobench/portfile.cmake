# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/nanobench
    REF v4.3.7
    SHA512 2f5b9573e220b507586c8586903489bd7dc2a8a09da07bd2454842a4c33c0323b0911ebeb902d5098c7dd9c96925d9bc3d4ca62fc5798f630b4b4d3e75d117a7
    HEAD_REF master
    PATCHES
        fix-cmakefile.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
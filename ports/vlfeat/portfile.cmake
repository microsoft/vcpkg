include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/vlfeat
    REF 1.0.0
    SHA512 845c2518885386f3ea6725d440e4a0d8e7d8a835d80251d79f1b3c50e23af449986ad7356f52d3c1d4eca47c61c561352220382e6b071ad201c2550ae40e80ed
    HEAD_REF cDc
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_STATIC_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_DYNAMIC_LIBS}
        -DBUILD_STATIC_RUNTIME=${BUILD_STATIC_CRT}
        -DBUILD_APPS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/vlfeat RENAME copyright)

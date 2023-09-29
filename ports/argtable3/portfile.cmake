vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO argtable/argtable3
    REF "v${VERSION}"
    SHA512 623197142fd1749b2fd5bc3e51758ae49c58ec8699b6afa5ecb2d0199d98f9c05366f92c5169c8039b5c417f4774fb4a09c879a7b04ddbed9d5e43585692ed7f
    HEAD_REF master
    PATCHES Fix-dependence-getopt.patch
)

set(ARGTABLE3_REPLACE_GETOPT ON)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
   set(ARGTABLE3_REPLACE_GETOPT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGTABLE3_ENABLE_CONAN=OFF
        -DARGTABLE3_ENABLE_TESTS=OFF
        -DARGTABLE3_ENABLE_EXAMPLES=OFF
        -DARGTABLE3_REPLACE_GETOPT=${ARGTABLE3_REPLACE_GETOPT}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

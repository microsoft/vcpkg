vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO argtable/argtable3
    REF 7704006f3cbb556e11da80a5b97469075a32892e # 3.2.1 + minor patches including ARGTABLE3_ENABLE_EXAMPLES support
    SHA512 c51aa0a33a247c3801e36ca5d9523acefa31f21a34c1e86965a39290c1b437785e4d7e0ae80a65d811803b8fcbbc3a96ba3d6aefaea9bda15abc0f38bd1f45cc
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

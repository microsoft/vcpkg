vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Get c4core src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/c4core
    REF "v${VERSION}"
    SHA512 e96d91daeba30a5caf1772a1fbcdd4011e42e112cd560652d23d61089ef751f88c305abc41b17f45652b44090a3b4e8d853acc1bc32ce8f6f46b3ad410028e9f
    HEAD_REF master
    PATCHES
        fix_gcc_48.patch
)

# Get cmake scripts for c4core
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_CMAKE
    REPO biojppm/cmake
    REF 95b2410e31ebf28b56a4fffffef52c7d13d657ad
    SHA512 0aede5089f1db81f976860b20e76f759ddb2c8dceb3b13d3521db65d67b5355083aa370eec245fe7810f3e6702c7ab0e42cae63b0b979c2118c09bf2ae8567ea
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME "${SOURCE_PATH_CMAKE}" "${SOURCE_PATH}/cmake")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_DEBUGBREAK
    REPO biojppm/debugbreak
    REF 5dcbe41d2bd4712c8014aa7e843723ad7b40fd74
    SHA512 8c63cbab94c049d6f04a48b9de73f22c50ed1e68eba2b77a0fdcb63952d88b1f7248c59e3f4d519c1211a93f378c0200f62fae5a2596a1decd5df18204d4f488
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/src/c4/ext/debugbreak")
file(RENAME "${SOURCE_PATH_DEBUGBREAK}" "${SOURCE_PATH}/src/c4/ext/debugbreak")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_FAST_FLOAT
    REPO fastfloat/fast_float
    REF 052975dd5f8166d0f9e4a215fa75a349d5985b91
    SHA512 28c1f88b6afbade3cfae892292957e7e239bf8e887639fc66b7d627fb39e17a3390854fee76af6c19e2bd81fb35f29b0dec8495dc3092b884d3aae9a63867c16
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/src/c4/ext/fast_float")
file(RENAME "${SOURCE_PATH_FAST_FLOAT}" "${SOURCE_PATH}/src/c4/ext/fast_float")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/c4core)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/c4core)
endif()

# Fix paths in config file
file(READ "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" _contents)
string(REGEX REPLACE [[[ \t\r\n]*"\${PACKAGE_PREFIX_DIR}[\./\\]*"]] [["${PACKAGE_PREFIX_DIR}/../.."]] _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

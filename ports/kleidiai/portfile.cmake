vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    message(STATUS "kleidiai only supports arm64 — skipping build for ${VCPKG_TARGET_ARCHITECTURE}.")
    return()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARM-software/kleidiai
    REF "v${VERSION}"
    SHA512 793bb36aaf32f72f78e87cea4f9971f75d160b8a18e5a06e4c234c6cb7a736fb359a80e3be56b91b265b5e478e52c277b9dfd405633012d26bcf5692e52051c3
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DKLEIDIAI_BUILD_TESTS=OFF
        -DKLEIDIAI_BUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/KleidiAI"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share") # Avoids empty debug folder in the zip.

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/Apache-2.0.txt")
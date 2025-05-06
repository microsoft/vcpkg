vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    message(STATUS "kleidiai only supports arm64 — skipping build for ${VCPKG_TARGET_ARCHITECTURE}.")
    return()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARM-software/kleidiai
    REF 60aaa7d75ebc461c6bd6a659d02da8235645220b
    SHA512 24d93bcc52b8529317c1f0c45cb6ffe892f459c5509966a033de79d35b9525ded23ebfdda9e4f17966c13b719d76f0278321dc21df28c630e4b370c92df9095a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DKLEIDIAI_BUILD_TESTS=OFF
        -DKLEIDIAI_BUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()
# The following line of code doesn't work because kleidiai_arm64-windows/debug/share/kleidiai' does not exist.
#vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share") # Avoids empty debug folder in the zip.

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/Apache-2.0.txt")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    message(FATAL_ERROR "kleidiai port only supports arm64 architecture.  Skipping build for ${VCPKG_TARGET_ARCHITECTURE}.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARM-software/kleidiai
    REF 81480ed1de6a3936b3b09ac071013e4afd445881
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
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share") # Avoids empty debug folder in the zip.

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/BSD-3-Clause.txt")
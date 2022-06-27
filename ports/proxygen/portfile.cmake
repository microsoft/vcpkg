vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF v2022.03.21.00
    SHA512 66dfd40e45b884d64be9c06b110caaa9333116c402312ee8eb0c21f0ab569ea31b9e4fb676c68b96730abbff0b74d139f5e39e702cd958c24ce0fe76f353fbe9
    HEAD_REF master
    PATCHES
        remove-register.patch
        fix-zstd-zlib-dependency.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES proxygen_curl proxygen_echo proxygen_proxy proxygen_push proxygen_static AUTO_CLEAN)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/proxygen)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF 0c932f6c57095838494520ec4ce7243a7f0c1234  #v2022.07.11.00
    SHA512 496189c37be8f42821cb5357e501b02f013858f1917854000777ac5c0403d078837e89dc3eef5f66f30f83c7506e40316d730725d7f97070090ac6549e766093
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

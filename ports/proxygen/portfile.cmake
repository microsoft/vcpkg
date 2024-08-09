vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF "v${VERSION}"
    SHA512 faef86bb3829f5ee38b4037a245a1f65406b65a416d393bf4aab91af4689a728dc54fc1e00aab7f4048e706d2940e31c6e7eb0f3c09ad52be1f5988a3a30620d
    HEAD_REF main
    PATCHES
        remove-register.patch
        fix-zstd-zlib-dependency.patch
        fix-dependency.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES hq proxygen_curl proxygen_echo proxygen_h3datagram_client proxygen_httperf2 proxygen_proxy proxygen_push proxygen_static AUTO_CLEAN)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/proxygen)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF "v${VERSION}"
    SHA512 598e4e170398c6a95ef4ab4f8826b716b74177f59f047d85427a53d2e51608c92d8130876c50cd51110f35a6fb4ad8b2969ee0ce64e94bcac808cec3ae0fc88f
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

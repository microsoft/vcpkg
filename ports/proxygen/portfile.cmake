vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF "v${VERSION}"
    SHA512 c9d75e1d6e4bf20b5b9085d780ca0cc5fda19d3a20d8af837d17581922df7751c993fb0a7d3cbd3a318227a2edffbe9e29c03c6f2bb6c4e912f5e5776178943b
    HEAD_REF master
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

vcpkg_copy_tools(TOOL_NAMES proxygen_curl proxygen_echo proxygen_proxy proxygen_push proxygen_static AUTO_CLEAN)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/proxygen)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

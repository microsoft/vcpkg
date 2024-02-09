vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rockdaboot/libpsl
    REF "${VERSION}"
    SHA512 "d8e224b2ce5d9a6ac78700eb8975d09aef4e5af7db29539e5e339c5cd100f1272371fe45757ab5383ddbcd569bdf9d697a78932ea9fdf43ff48d3cea02f644cd"
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/public_suffix_list.dat" DESTINATION "${SOURCE_PATH}/list")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddocs=false
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES psl AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
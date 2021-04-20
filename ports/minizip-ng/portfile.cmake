vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/minizip-ng
    REF 3.0.1
    SHA512 98c9bdcea79a88a2dd69cec6c49f8565edf78ab9cddbf0e85e08b049b300b187f176bf57d5a894bf777bec0a097e46ecc05f78dab9cd5726fd473ffd8718dce0
    HEAD_REF master
    PATCHES Modify-header-file-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
        -DMZ_PROJECT_SUFFIX:STRING=-ng
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/minizip-ng/copyright" COPYONLY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ddiakopoulos/tinyply
    REF ca7b279fb6c9af931ffdaed96a3b11ca3ccd79ea
    SHA512 d3adfe7cce849a14fd473cfd67baef0163d4e45ff32724516270d5893a18086f7ac17d87bda5c33381442766849b41516bd2c7757e97038c95af0c70d5f0edde
    HEAD_REF master
    PATCHES
        # TODO: Remove this patch if https://github.com/ddiakopoulos/tinyply/pull/41 was accepted.
        fix-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSHARED_LIB=${SHARED_LIB}
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License
file(READ "${SOURCE_PATH}/readme.md" readme_contents)
string(FIND "${readme_contents}" "License" license_line_pos)
string(SUBSTRING "${readme_contents}" ${license_line_pos} -1 license_contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${license_contents}")

vcpkg_fixup_pkgconfig()

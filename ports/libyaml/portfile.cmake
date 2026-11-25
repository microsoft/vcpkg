if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES fix-POSIX_name.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yaml/libyaml
    REF "${VERSION}"
    SHA512 114e8960194c342556ec4f8908f70a578b6afa792c353d56350d521b43ce36f40fb487020b7ebcc81b36525f1464d4b9ba2bc4aa87bb7b6d0ac864779d31ebd0
    HEAD_REF master
    PATCHES
        ${PATCHES}
        export-pkgconfig.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DINSTALL_CMAKE_DIR=share/yaml
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/yaml.h" "defined(YAML_DECLARE_STATIC)" "1")
endif()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME yaml CONFIG_PATH share/yaml)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/config.h"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

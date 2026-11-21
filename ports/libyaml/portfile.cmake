if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES fix-POSIX_name.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yaml/libyaml
    REF "${VERSION}"
    SHA512 b9bf8d530bdb1f644c133c1cff7e4649f86b1db71a33b324f5a0a7aa4b956cab566afe71ef40302578b5d351761dcce82ecc6a17c7bc352f78238d468e0ea1da
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

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME yaml CONFIG_PATH share/yaml)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/config.h"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

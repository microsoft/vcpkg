if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF "v${VERSION}"
    SHA512 b3b02079434b87f4a72b1dfb772be67827d9a7d234e2aaa4cafccd187e3ce706862f7f4ab9e4d89cfe7eaf9a29c1f62215e5c80ecda6265f6b93ac8b609a2c4c
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/deps")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLSQPACK_TESTS=OFF
        -DLSQPACK_BIN=OFF
        -DLSQPACK_XXH=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ls-qpack)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/wincompat/sys/queue.h"
)

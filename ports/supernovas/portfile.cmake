vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Smithsonian/SuperNOVAS
    REF "v${VERSION}"
    SHA512 4babecc41fbdfa515f2aea2f07f6b052605d16c1c3d6aa3ab44d13de6cf4ccd1a59f4e72e269623fd4ea73b83b72ff7bd6068c8cb09866a535412e50ee040446
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_CALCEPH=OFF
)

vcpkg_apply_patches(
    SOURCE_PATH "${SOURCE_PATH}"
    PATCHES android.patch
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

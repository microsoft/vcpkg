vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 fa0c9154563982a9b6bff684ce37fb29ed817e52c686081eb0da62b9630defc6006475c17d7823108023a7d50b73762875664e0a5d73c9749b11c52f4782fac6
    HEAD_REF master
    PATCHES spdlog_include.patch
)

vcpkg_list(SET options)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_list(APPEND options "-DBUILD_STATIC=1")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSYSTEM_SPDLOG=ON
        ${options}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")


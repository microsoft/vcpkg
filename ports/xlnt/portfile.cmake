# Download the xlnt source code
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xlnt-community/xlnt
    REF "v${VERSION}"
    SHA512 1051c2af1d37f3b0122a89fba2cb43d5779a3b8012cc978a5366e6ab721dc067819a6d301e0ebe214a1b0bac0281c8e1b7f56bfa5f41ec80dbf88d0cbaaaeb05
    HEAD_REF master
    PATCHES
        fix-not-found-include.patch
        fix-configure-dependencies.patch
)

# Download the libstudxml dependencies and copy it to the third-party folder as expected by xlnt (outside vcpkg libstudxml is included as a git submodule)
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_LIBSTUDXML
    URL https://git.codesynthesis.com/libstudxml/libstudxml.git
    FETCH_REF v1.1.0-b.10+2
    REF c8015cb75d7d3b3c499ec86b84d099c4c1ab942b
    HEAD_REF master
)
file(COPY "${SOURCE_PATH_LIBSTUDXML}/" DESTINATION "${SOURCE_PATH}/third-party/libstudxml")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(STATIC OFF)
else()
    set(STATIC ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS -DTESTS=OFF -DSAMPLES=OFF -DBENCHMARKS=OFF -DSTATIC=${STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/xlnt)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

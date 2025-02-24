vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dvidelabs/flatcc
    REF "v${VERSION}"
    SHA512 46ba5ca75facc7d3360dba797d24ae7bfe539a854a48831e1c7b96528cf9594d8bea22b267678fd7c6d742b6636d9e52930987119b4c6b2e38d4abe89b990cae
    HEAD_REF main
    PATCHES
        fix_install_dir.patch
)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" FLATCC_DYNAMIC)

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND EXTRA_OPTIONS "-DFLATCC_INSTALL_LIB=bin")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${FLATCC_DYNAMIC}
        -DFLATCC_INSTALL=ON
        -DFLATCC_ALLOW_WERROR=OFF
        -DFLATCC_TEST=OFF
        -DFLATCC_CXX_TEST=OFF
        -DFLATCC_RTONLY=ON
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
        ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

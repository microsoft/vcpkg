vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/veigar
    HEAD_REF master
    REF "${VERSION}"
    SHA512 dce0312bd5792e1c4a084b23c331bb5b30459b8e43b325e630800e2ebe929099defb000c889bd09ab94b2417b0169614465c11ca9ed845236542a6c36b9947fc
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" VEIGAR_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVEIGAR_USE_STATIC_CRT:BOOL=${VEIGAR_USE_STATIC_CRT}
        -DVEIGAR_BUILD_TESTS:BOOL=OFF
        -DVEIGAR_BUILD_EXAMPLES:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

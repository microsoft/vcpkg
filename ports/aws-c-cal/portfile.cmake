vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-cal
    REF "v${VERSION}"
    SHA512 b3a00aa7cd322e16216744f622b7e36028da4a7a085e7bd967d5946ca4026f8d88c1d3891e970e2d8ae96939cb2c1b4ae30f8ca8117187877309979810863f36
    HEAD_REF master
    PATCHES remove-libcrypto-messages.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

string(REPLACE "dynamic" "shared" subdir "${VCPKG_LIBRARY_LINKAGE}")
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/${PORT}/cmake/${subdir}" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/${PORT}/cmake")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" [[/${type}/]] "/")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/${PORT}"
)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

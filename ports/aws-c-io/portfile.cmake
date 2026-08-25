vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-io
    REF "v${VERSION}"
    SHA512 e812fd7168c0b71cc98a7f835dd3dd48174d0c14e5d92ed10b5ecf558fc29bed2b4adf32f55408ee3ed7f54dfaa50d9f12334f5c89b0d76cedb800fb08daf483
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

string(REPLACE "dynamic" "shared" subdir "${VCPKG_LIBRARY_LINKAGE}")
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}/${subdir}" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" [[/${type}/]] "/")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/${PORT}"
)

vcpkg_copy_pdbs()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/NOTICE"
)

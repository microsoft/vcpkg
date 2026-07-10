vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-s3
    REF "v${VERSION}"
    SHA512 7f478e6cd1b9b5236c95f0a3e25a3d3331db4d6b47c9971a242d6daada9c72f929b04b8de69b25bf6d6ff4fa9674babcc32131d58b06f764bdcfa79b52e38d79
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        endpoint-resolver AWS_ENABLE_S3_ENDPOINT_RESOLVER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
        ${FEATURE_OPTIONS}
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

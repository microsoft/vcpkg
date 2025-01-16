vcpkg_download_distfile(
    GRPC_PATCH
    URLS https://github.com/etcd-cpp-apiv3/etcd-cpp-apiv3/commit/216b86f8d763acf88e4ed7265f983b57c12da2df.patch?full_index=1
    SHA512 5a2c843c41d6c1e84333773cbec9fd3e1c6501d325a053a2c02c8e3aa752422158a6239c1f47a1d8d7ac129a45f3385efce543ec7260b7309f8b76d2ea7a1ca2
    FILENAME 216b86f8d763acf88e4ed7265f983b57c12da2df.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO etcd-cpp-apiv3/etcd-cpp-apiv3
    REF "v${VERSION}"
    SHA512 52f3cf14ad5594c04a086786d3459aee0986017a0314dfdf3fff1715677ff7a7ebedcc0afc28e1d7e75b8991ab6ede95eeded472d85ac1def84343cc1c54a30a
    HEAD_REF master
    PATCHES
        "${GRPC_PATCH}"
)
file(WRITE "${SOURCE_PATH}/cmake/UploadPPA.cmake" "")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_ETCD_TESTS=OFF
        -DETCD_W_STRICT=OFF
        "-DGRPC_CPP_PLUGIN=${CURRENT_HOST_INSTALLED_DIR}/tools/grpc/grpc_cpp_plugin${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DProtobuf_PROTOC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DOpenSSL_DIR=${CURRENT_INSTALLED_DIR}" # don't look for homebrew
    MAYBE_UNUSED_VARIABLES
        OpenSSL_DIR
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/etcd-cpp-api)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/etcd-cpp-api-config.cmake"
    [[ETCD_CPP_HOME "${CMAKE_CURRENT_LIST_DIR}/../../.."]] 
    [[ETCD_CPP_HOME "${CMAKE_CURRENT_LIST_DIR}/../.."]]
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

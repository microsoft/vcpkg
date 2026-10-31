# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF "v${VERSION}"
    SHA512 b9a689f25284206969f31ba382abd06cd4ed69ee6a118af3484aaa17b68aebefddc97a4e722e3bde8fa39b737677cb09cbd3d3e6f2a573ac4ba1fb718478b79a
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
# Copy the tinygltf header files and fix the path to json
vcpkg_replace_string("${SOURCE_PATH}/tiny_gltf.h" "#include \"json.hpp\"" "#include <nlohmann/json.hpp>")
file(INSTALL
        "${SOURCE_PATH}/tiny_gltf.h"
        "${SOURCE_PATH}/tiny_gltf_v3.h"
        "${SOURCE_PATH}/tinygltf_json.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

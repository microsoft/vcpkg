# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF v2.2.0
    SHA512 5a63fab31dd49e25fe2a32f66bbcae5a6340ced403dc51de65ee7363bb9b358e546bbecd116a53062099f90a2579a5178dcc5c4268d4b99c0afe30fac20ad7cf
    HEAD_REF master
)

file(READ ${SOURCE_PATH}/tiny_gltf.h TINY_GLTF_H)
string(REPLACE "#include \"json.hpp\""
               "#include <nlohmann/json.hpp>" TINY_GLTF_H "${TINY_GLTF_H}")

file(WRITE ${CURRENT_PACKAGES_DIR}/include/tiny_gltf.h "${TINY_GLTF_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

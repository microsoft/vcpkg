# Header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF v2.2.0
    SHA512 5a63fab31dd49e25fe2a32f66bbcae5a6340ced403dc51de65ee7363bb9b358e546bbecd116a53062099f90a2579a5178dcc5c4268d4b99c0afe30fac20ad7cf
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinygltf/LICENSE)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinygltf/LICENSE ${CURRENT_PACKAGES_DIR}/share/tinygltf/copyright)

# Copy the tinygltf header files
file(COPY ${SOURCE_PATH}/tiny_gltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

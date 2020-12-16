# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF 91da29972987bb4d715a09d94ecd2cefd3a487d4  #v2.4.2
    SHA512 bede1f995b8f6cdab04140ab284576444ddb5baa8894150ac697e53bafbe03c339c274a2b9559572751a9408b33750d86105d8d24ebccbdfbc98555e7b3a1efd
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinygltf/LICENSE)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinygltf/LICENSE ${CURRENT_PACKAGES_DIR}/share/tinygltf/copyright)

# Copy the tinygltf header files
file(COPY ${SOURCE_PATH}/tiny_gltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF 91da29972987bb4d715a09d94ecd2cefd3a487d4  #v2.4.2
    SHA512 bede1f995b8f6cdab04140ab284576444ddb5baa8894150ac697e53bafbe03c339c274a2b9559572751a9408b33750d86105d8d24ebccbdfbc98555e7b3a1efd
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
# Copy the tinygltf header files and fix the path to json
vcpkg_replace_string(${SOURCE_PATH}/tiny_gltf.h "#include \"json.hpp\"" "#include <nlohmann/json.hpp>")
file(INSTALL ${SOURCE_PATH}/tiny_gltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

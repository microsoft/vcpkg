vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF v2.5.0
    SHA512 f0e9c3f385deaf3c803edea05602da1cbf173e42c6946ec06b0ec6145f7f258a2429921a1c9baf0ca48353219fedeedfe4ad4516429c970ec4c27d7538873003
    HEAD_REF master
)

# Header-only library
# Copy the tinygltf header files and fix the path to json
vcpkg_replace_string("${SOURCE_PATH}/tiny_gltf.h" "#include \"json.hpp\"" "#include <nlohmann/json.hpp>")
file(INSTALL "${SOURCE_PATH}/tiny_gltf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(READ "${SOURCE_PATH}/tiny_gltf.h" tiny_gltf_header)
if(tiny_gltf_header MATCHES "base64.cpp and base64.h([^*]*)")
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "\n\nbase64 functions\n${CMAKE_MATCH_1}")
endif()

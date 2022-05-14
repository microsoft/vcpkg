if(NOT FEATURES MATCHES "json")
    message(FATAL_ERROR "At least one JSON feature (default-json, rapidjson) must be selected.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF v2.5.0
    SHA512 f0e9c3f385deaf3c803edea05602da1cbf173e42c6946ec06b0ec6145f7f258a2429921a1c9baf0ca48353219fedeedfe4ad4516429c970ec4c27d7538873003
    HEAD_REF master
    PATCHES
        json-includes.patch
        dependency-control.patch
)

# Header-only library
vcpkg_check_features(
    OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        default-json    VCPKG_TINYGLTF_WITH_DEFAULT_JSON
        draco           VCPKG_TINYGLTF_WITH_DRACO
        rapidjson       VCPKG_TINYGLTF_WITH_RAPIDJSON
        stb             VCPKG_TINYGLTF_WITH_STB
)
configure_file("${SOURCE_PATH}/tiny_gltf.h" "${CURRENT_PACKAGES_DIR}/include/tiny_gltf.h" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(READ "${SOURCE_PATH}/tiny_gltf.h" tiny_gltf_header)
if(tiny_gltf_header MATCHES "base64.cpp and base64.h([^*]*)")
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "\n\nbase64 functions\n${CMAKE_MATCH_1}")
endif()

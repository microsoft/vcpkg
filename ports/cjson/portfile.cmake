vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaveGamble/cJSON
    REF v1.7.15
    SHA512 0b32a758c597fcc90c8ed0af493c9bccd611b9d4f9a03e87de3f7337bb9a28990b810befd44bc321a0cb42cbcd0b026d45761f9bab7bd798f920b7b6975fb124
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        utils ENABLE_CJSON_UTILS
)

if(CMAKE_HOST_WIN32)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_PUBLIC_SYMBOLS)
    string(COMPARE NOTEQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DENABLE_HIDDEN_SYMBOLS)
else()
    set(ENABLE_PUBLIC_SYMBOLS OFF)
    set(DENABLE_HIDDEN_SYMBOLS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_AND_STATIC_LIBS=OFF
        -DCJSON_OVERRIDE_BUILD_SHARED_LIBS=OFF
        -DENABLE_PUBLIC_SYMBOLS=${ENABLE_PUBLIC_SYMBOLS}
        -DENABLE_HIDDEN_SYMBOLS=${DENABLE_HIDDEN_SYMBOLS}
        -DENABLE_TARGET_EXPORT=ON # Export CMake config files
        -DENABLE_CJSON_TEST=OFF
        -DENABLE_FUZZING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cJSON)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(READ "${CURRENT_PACKAGES_DIR}/include/cjson/cJSON.h" _contents)
if(ENABLE_PUBLIC_SYMBOLS)
    string(REPLACE "defined(CJSON_HIDE_SYMBOLS)" "0 /* defined(CJSON_HIDE_SYMBOLS) */" _contents "${_contents}")
    string(REPLACE "defined(CJSON_EXPORT_SYMBOLS)" "0 /* defined(CJSON_EXPORT_SYMBOLS) */" _contents "${_contents}")
    string(REPLACE "defined(CJSON_IMPORT_SYMBOLS)" "1 /* defined(CJSON_IMPORT_SYMBOLS) */" _contents "${_contents}")
else()
    string(REPLACE "defined(CJSON_HIDE_SYMBOLS)" "1 /* defined(CJSON_HIDE_SYMBOLS) */" _contents "${_contents}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/cjson/cJSON.h" "${_contents}")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

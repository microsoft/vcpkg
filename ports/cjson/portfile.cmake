vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaveGamble/cJSON
    REF "v${VERSION}"
    SHA512 7b22bdd05b8e0bf8b24ab79db128dbab9f8c2c167f4b1d3073922b8ff1e0f0e8917322283d6d4091002f014f42692984f4f641761f05965d3b66fb3eca14dc46
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
        -DENABLE_CUSTOM_COMPILER_FLAGS=OFF
        -DENABLE_FUZZING=OFF
	-DCMAKE_POLICY_DEFAULT_CMP0057=NEW
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

vcpkg_fixup_pkgconfig()

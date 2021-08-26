vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaveGamble/cJSON
    REF 95368da1a13c1ced5507bb5b0a457729af34837c
    SHA512 e50fb7857573fac39bc9659004bd71483156677b4b1c7dd801470469162d1af2b1e3803fb4f1291b2b5defefb005ddd78b0efb01965626eecc00bc78b5f98c72
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cJSON)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(READ ${CURRENT_PACKAGES_DIR}/include/cjson/cJSON.h _contents)
if(ENABLE_PUBLIC_SYMBOLS)
    string(REPLACE "defined(CJSON_HIDE_SYMBOLS)" "0 /* defined(CJSON_HIDE_SYMBOLS) */" _contents "${_contents}")
    string(REPLACE "defined(CJSON_EXPORT_SYMBOLS)" "0 /* defined(CJSON_EXPORT_SYMBOLS) */" _contents "${_contents}")
    string(REPLACE "defined(CJSON_IMPORT_SYMBOLS)" "1 /* defined(CJSON_IMPORT_SYMBOLS) */" _contents "${_contents}")
else()
    string(REPLACE "defined(CJSON_HIDE_SYMBOLS)" "1 /* defined(CJSON_HIDE_SYMBOLS) */" _contents "${_contents}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/cjson/cJSON.h "${_contents}")

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

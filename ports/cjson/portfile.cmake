include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaveGamble/cJSON
    REF v1.7.12
    SHA512 d767b7261eff3a1a50ea46cc5573f9504f5734a891ea211ad348835bfb4b80acf7f744da2d34bb1fa270cd4d44576c21bc6f52c0604b7e6ffdeb61ecb396b376
    HEAD_REF master
    PATCHES
        fix-install-path.patch
)

if("utils" IN_LIST FEATURES)
    set(ENABLE_CJSON_UTILS ON)
else()
    set(ENABLE_CJSON_UTILS OFF)
endif()

if(CMAKE_HOST_WIN32)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_PUBLIC_SYMBOLS)
else()
    set(ENABLE_PUBLIC_SYMBOLS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_AND_STATIC_LIBS=OFF
        -DCJSON_OVERRIDE_BUILD_SHARED_LIBS=OFF
        -DENABLE_PUBLIC_SYMBOLS=${ENABLE_PUBLIC_SYMBOLS}
        -DENABLE_TARGET_EXPORT=ON # Export CMake config files
        -DENABLE_CJSON_UTILS=${ENABLE_CJSON_UTILS}
        -DENABLE_CJSON_TEST=OFF
        -DENABLE_FUZZING=OFF
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

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})

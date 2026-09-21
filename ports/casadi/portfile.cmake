vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO casadi/casadi
    REF "${VERSION}"
    SHA512 4750d2e9c7eda630bae02a8b8adb074a6e7ce361fd2a83425e3ac215a1446e90316ddfb0d4e3c1ecf3264c441833749c5bb8c6cecb96f1fd7b283b7dfdcc6a4f
    HEAD_REF main
    PATCHES
        find-system-zlib-ghc-filesystem.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(ENABLE_SHARED ON)
    set(ENABLE_STATIC OFF)
else()
    set(ENABLE_SHARED OFF)
    set(ENABLE_STATIC ON)
endif()

# Do not build deepbind on unsupported platforms
if(VCPKG_TARGET_IS_ANDROID)
    set(WITH_DEEPBIND OFF)
else()
    set(WITH_DEEPBIND ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fatrop WITH_FATROP
        fmu    WITH_FMI2
        fmu    WITH_FMI3
        fmu    WITH_TINYXML
        fmu    WITH_LIBZIP
        fmu    WITH_ZLIB
        fmu    WITH_GHC_FILESYSTEM
        onnx   WITH_ONNX
        onnx   WITH_PROTOBUF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
     ${FEATURE_OPTIONS}
     -DENABLE_STATIC=${ENABLE_STATIC}
     -DENABLE_SHARED=${ENABLE_SHARED}
     -DWITH_DEEPBIND=${WITH_DEEPBIND}
     -DWITH_SELFCONTAINED=OFF
     -DWITH_EXAMPLES=OFF
     -DWITH_BUILD_TINYXML=OFF
     -DWITH_QPOASES=OFF
     -DWITH_SUNDIALS=OFF
     -DWITH_CSPARSE=OFF
     -DLIB_PREFIX:PATH=lib
     -DBIN_PREFIX:PATH=bin
     -DINCLUDE_PREFIX:PATH=include
     -DCMAKE_PREFIX:PATH=share/${PORT}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.txt"
    "${SOURCE_PATH}/external_packages/FMI-Standard-2.0.2/LICENSE.txt"
    "${SOURCE_PATH}/external_packages/FMI-Standard-3.0/LICENSE.txt"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_tools(TOOL_NAMES casadi-cli AUTO_CLEAN)

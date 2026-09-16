vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO casadi/casadi
    REF "${VERSION}"
    SHA512 9706f0209333ff6636ec5fe545feaf9cb730e86356667d4f01ff922f8ed55094426f83a60ac54ea080143d879da8d1cb77bdfbd8c8eced757addfacbb03efc57
    HEAD_REF main
    PATCHES
        fmu-guard-fmi3.patch
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
     -DENABLE_STATIC=${ENABLE_STATIC}
     -DENABLE_SHARED=${ENABLE_SHARED}
     -DWITH_DEEPBIND=${WITH_DEEPBIND}
     -DWITH_SELFCONTAINED=OFF
     # CasADi compiles the vendored FMI standard headers (BSD-2-Clause) into the
     # core library by default. They are not available as a separate package, so
     # disable FMI import rather than redistribute third-party code from this port.
     -DWITH_FMI2=OFF
     -DWITH_FMI3=OFF
     -DWITH_EXAMPLES=OFF
     -DWITH_TINYXML=OFF
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_tools(TOOL_NAMES casadi-cli AUTO_CLEAN)

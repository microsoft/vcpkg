vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO casadi/casadi
    REF "${VERSION}"
    SHA512 ebd1d91f18b29620c8898fd014e35eefce2d621f9a698a14454b478cded78087bffa3651d808908a16ed8864571c7ddae99e387e53cb79a451ca60a8d690c8bb
    HEAD_REF main
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

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_tools(TOOL_NAMES casadi-cli AUTO_CLEAN)

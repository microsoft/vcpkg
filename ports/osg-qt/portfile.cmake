vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openscenegraph/osgQt
    REF 2cb70673a4e83a618290e7ee66d52402a94ec3f6
    SHA512 29aeb5b31e70d5b12e69de7970b36ab7d1541c984873384a46c6468394e8562688c46ef39179820990817c94f283c7836c2c6ff207eefe385086d850ba3f8306
    HEAD_REF master
    PATCHES
        OsgMacroUtils.patch
        fix-static-install.patch
        CMakeLists.patch
        use-lib.patch
        export-target.patch
)

file(COPY "${CURRENT_PORT_DIR}/osgQOpenGLConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} 
    PATCHES 
        fix-static-1.patch
)

if(VCPKG_TARGET_IS_OSX)
    string(APPEND VCPKG_CXX_FLAGS " -stdlib=libc++")
    string(APPEND VCPKG_C_FLAGS "") # both must be set
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPTIONS -DDYNAMIC_OPENSCENEGRAPH=ON)
else()
    set(OPTIONS -DDYNAMIC_OPENSCENEGRAPH=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DBUILD_OSG_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "share/cmake/osg-qt"
    PACKAGE_NAME "osg-qt"
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${SOURCE_PATH}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

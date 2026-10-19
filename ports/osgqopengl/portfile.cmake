vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emminizer/osgQOpenGL
    HEAD_REF main
    REF "v4.1.2"
    SHA512 d3d6d1e879ed6c08ab83c2a88fff5ba1668dddff174518d4c46dae5355c2ab69caf1a0dd20a25c6d355f68c0f75022f7fad3dfb4013b099a51418cc37b63ded0
)

# Upstream defaults DYNAMIC_OPENSCENEGRAPH to ON and builds SHARED libraries
# unconditionally; honor VCPKG_LIBRARY_LINKAGE so static triplets get static libs.
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" _DYNAMIC_OSGQOPENGL)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDESIRED_QT_VERSION=6
        -DBUILD_OSG_EXAMPLES=OFF
        -DOSG_MSVC_VERSIONED_DLL=OFF
        -DDYNAMIC_OPENSCENEGRAPH=${_DYNAMIC_OSGQOPENGL}
    MAYBE_UNUSED_VARIABLES
        OSG_MSVC_VERSIONED_DLL
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME osgQOpenGL
    CONFIG_PATH share/cmake/osgQOpenGL
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

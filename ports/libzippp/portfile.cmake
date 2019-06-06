# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF libzippp-v2.1-1.5.2
    SHA512 15074dafe60a9563a6369f9bb80077f117bd5d0fc4e5d29d9dc9b54e440c912826945f787a907a7c9d239b2d856fe3cf393010d9d01322e8532bc10fae72fa06
    HEAD_REF master
    PATCHES
        "fixed-location-of-libs.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DVCPKG_INSTALLED_TRIPLET=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}
)

vcpkg_build_cmake(TARGET ALL_BUILD)

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include/
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(COPY
    "${SOURCE_PATH}\\src\\libzippp.h"
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/
)
file(COPY
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/libzippp.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/libzippp_static.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/libzippp.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/libzippp_static.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)


file(COPY
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/libzippp.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/libzippp.pdb"
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/libzippp.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/libzippp.pdb"
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzippp RENAME copyright)

#file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzippp)
file(GLOB LIBZIPPP_CMAKE_CONFIG
  "${CMAKE_CURRENT_LIST_DIR}//libzippp-config*.cmake"
)
file(COPY ${LIBZIPPP_CMAKE_CONFIG} DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzippp)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME libzippp MODULE)

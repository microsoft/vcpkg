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
    REPO Thorius/rapidcheck
    REF a195151261e3480fd22a8878097213054181c7d8
    SHA512 166161c3033e9722cface1aff778f1d27629e948538de781b921022d4e0208672532e2af9ad2231718e3f10538d71d26f98232b1fc9d6abec51a94576ba70d6d
    HEAD_REF improve-cmake-instal
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Warning: RapidCheck does not support dynamic linking. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
# Keep this variable in case RapidCheck can eventually be used as a shared library.
set(RC_SHARED_LIB OFF)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DRC_INSTALL_ALL_EXTRAS=ON -DRC_BUILD_SHARED_LIB=${RC_SHARED_LIB}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/rapidcheck/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidcheck RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME rapidcheck)

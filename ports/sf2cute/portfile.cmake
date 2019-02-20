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
    REPO markusobi/sf2cute
    REF b86e0c177b1cc8605c67a16f39e994dcfd35e294
    SHA512 d61b768bbfd0c66d1fac637727f31093755c75dae48ee866fd61e04f50c216bbb8496cac4616153f5211bd3224d43bca358e32f7557da06019a1afec67c245d1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
		-DDISABLE_INSTALL_EXECUTABLES=ON
)

vcpkg_install_cmake()

# headers shall be installed only once
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/sf2cute/sf2cute-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute/cmake/)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/sf2cute/sf2cute-targets.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute/cmake/)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/sf2cute/sf2cute-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute/cmake/)

file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/sf2cute/sf2cute-targets-release.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute/cmake/)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/sf2cute/sf2cute-targets-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute/)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME sf2cute)

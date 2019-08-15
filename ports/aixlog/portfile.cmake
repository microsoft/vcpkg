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
	REPO badaix/aixlog
	REF  v1.2.1
	SHA512 776558fdd911f0cc9e8d467bf8e00a1930d2e51bb8ccd5f36f95955fefecab65faf575a80fdaacfe83fd32808f8b9c2e0323b16823e0431300df7bc0c1dfde12
    )
    


file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)	
file(COPY ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)


# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aixlog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/aixlog/LICENSE ${CURRENT_PACKAGES_DIR}/share/aixlog/copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME aixlog)

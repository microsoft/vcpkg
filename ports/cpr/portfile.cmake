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
    REPO whoshuu/cpr
    REF 1.3.0
    SHA512 fd08f8a592a5e1fb8dc93158a4850b81575983c08527fb415f65bd9284f93c804c8680d16c548744583cd26b9353a7d4838269cfc59ccb6003da8941f620c273
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/force_static_library.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS 
		-DBUILD_CPR_TESTS=OFF 
		-DUSE_SYSTEM_CURL=ON
)

vcpkg_build_cmake()

file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/cpr.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/cpr/CMakeFiles/cpr.dir/cpr.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/cpr.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/cpr/CMakeFiles/cpr.dir/cpr.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cpr/LICENSE ${CURRENT_PACKAGES_DIR}/share/cpr/copyright)

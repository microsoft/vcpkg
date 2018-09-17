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
#set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tinyspline-0.2.0)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msteinbeck/tinyspline
    REF 0.2.0
    SHA512 50cf4927b311eeca6de7954f1b8d585cbf71355f5e5b0aac2f92f5f4ba37986df16eb3251f94a2304d27dab27d4f6b838b410f53e30de28bab53facf194eb640
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}/src
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
)
    
#vcpkg_download_distfile(ARCHIVE
#    URLS "https://github.com/msteinbeck/tinyspline/archive/0.2.0.tar.gz"
#    FILENAME "0.2.0.tar.gz"
#    SHA512 50cf4927b311eeca6de7954f1b8d585cbf71355f5e5b0aac2f92f5f4ba37986df16eb3251f94a2304d27dab27d4f6b838b410f53e30de28bab53facf194eb640
#)
#vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
	${OPTIONS}
	#-DTINYSPLINE_DISABLE_CSHARP=ON
	#-DTINYSPLINE_DISABLE_D=ON
	#-DTINYSPLINE_DISABLE_GOLANG=ON
	#-DTINYSPLINE_DISABLE_JAVA=ON
	#-DTINYSPLINE_DISABLE_LUA=ON
	#-DTINYSPLINE_DISABLE_OCTAVE=ON
	#-DTINYSPLINE_DISABLE_PHP=ON
	#-DTINYSPLINE_DISABLE_PYTHON=ON
	#-DTINYSPLINE_DISABLE_R=ON
	#-DTINYSPLINE_DISABLE_RUBY=ON
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyspline RENAME copyright)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyspline RENAME copyright)

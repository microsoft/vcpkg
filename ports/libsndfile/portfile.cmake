# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libsndfile-6830c421899e32f8d413a903a21a9b6cf384d369)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/erikd/libsndfile/archive/6830c421899e32f8d413a903a21a9b6cf384d369.zip"
    FILENAME "libsndfile-1.0.29-6830c42.zip"
    SHA512 94b561f384606f2c3dccc79164ffb4f37b93cf96e102e8bc319b50acc0e27045eea61cbe49f25610151adbeb13cc1fd57ddbbeb76abddb0fb5027e0581b83bb6
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
	SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libsndfile-6830c421899e32f8d413a903a21a9b6cf384d369
	PATCHES
		"${CMAKE_CURRENT_LIST_DIR}/uwp-createfile-getfilesize.patch"
		"${CMAKE_CURRENT_LIST_DIR}/uwp-createfile-getfilesize-addendum.patch"
)

if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(CRT_LIB_STATIC 0)
elseif (VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CRT_LIB_STATIC 1)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_STATIC 1)
    set(BUILD_DYNAMIC 0)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_STATIC 0)
    set(BUILD_DYNAMIC 1)
endif()

option(BUILD_EXECUTABLES "Build sndfile tools and install to folder tools" OFF)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_PROGRAMS=${BUILD_EXECUTABLES} -DBUILD_EXAMPLES=0 -DBUILD_REGTEST=0 -DBUILD_TESTING=0 -DENABLE_STATIC_RUNTIME=${CRT_LIB_STATIC} -DBUILD_STATIC_LIBS=${BUILD_STATIC} -DBUILD_SHARED_LIBS=${BUILD_DYNAMIC}
    # Setting ENABLE_PACKAGE_CONFIG=0 has no effect
    # Avoid building tools in debug-build:
    OPTIONS_DEBUG -DBUILD_PROGRAMS=0
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/share/doc/libsndfile DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/libsndfile ${CURRENT_PACKAGES_DIR}/share/${PORT}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
file(COPY ${CURRENT_PACKAGES_DIR}/cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake )

if(BUILD_EXECUTABLES)
    file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${TOOLS})
endif(BUILD_EXECUTABLES)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/geographiclib-1.47)
vcpkg_download_distfile(ARCHIVE
    URLS "https://jaist.dl.sourceforge.net/project/geographiclib/distrib/GeographicLib-1.47-patch1.zip"
    FILENAME "geographiclib-1.47-patch1.zip"
    SHA512 d8fdfd7ae093057ec1a4ab922457fe71a3fb9975df5b673c276d62a0e9c4f212dc63652830b9d89e3890bc96aafd335992943cf6a1bce8260acf932d1eb7abfd
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/remove-tools-and-fix-version.patch"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DGEOGRAPHICLIB_LIB_TYPE=SHARED
        PREFER_NINJA # Disable this option if project cannot be built with Ninja
        # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
    )
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DGEOGRAPHICLIB_LIB_TYPE=STATIC
        PREFER_NINJA # Disable this option if project cannot be built with Ninja
        # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
    )
endif()

vcpkg_install_cmake()
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(GLOB GEOGRAPHICLIB_CMAKE_FILES ${CURRENT_PACKAGES_DIR}/cmake/*.cmake ${CURRENT_PACKAGES_DIR}/debug/cmake/*.cmake)
file(COPY ${GEOGRAPHICLIB_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/geographiclib)

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/geographiclib-targets.cmake GEOGRAPHICLIB_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}/include" "\${_IMPORT_PREFIX}/../include" GEOGRAPHICLIB_MODULE "${GEOGRAPHICLIB_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/geographiclib/geographiclib-targets.cmake "${GEOGRAPHICLIB_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/geographiclib-targets-debug.cmake GEOGRAPHICLIB_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/../debug" GEOGRAPHICLIB_DEBUG_MODULE "${GEOGRAPHICLIB_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/geographiclib/geographiclib-targets-debug.cmake "${GEOGRAPHICLIB_DEBUG_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/geographiclib-namespace-targets-debug.cmake GEOGRAPHICLIB_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/../debug" GEOGRAPHICLIB_DEBUG_MODULE "${GEOGRAPHICLIB_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/geographiclib/geographiclib-namespace-targets-debug.cmake "${GEOGRAPHICLIB_DEBUG_MODULE}")


file(READ ${CURRENT_PACKAGES_DIR}/cmake/geographiclib-targets-release.cmake GEOGRAPHICLIB_RELEASE_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/.." GEOGRAPHICLIB_RELEASE_MODULE "${GEOGRAPHICLIB_RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/geographiclib/geographiclib-targets-release.cmake "${GEOGRAPHICLIB_RELEASE_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/cmake/geographiclib-namespace-targets-release.cmake GEOGRAPHICLIB_RELEASE_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/.." GEOGRAPHICLIB_RELEASE_MODULE "${GEOGRAPHICLIB_RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/geographiclib/geographiclib-namespace-targets-release.cmake "${GEOGRAPHICLIB_RELEASE_MODULE}")


file(COPY ${CURRENT_BUILDTREES_DIR}/src/GeographicLib-1.47/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/geographiclib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/geographiclib/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/geographiclib/copyright)

file(GLOB EXE_FILES "${CURRENT_PACKAGES_DIR}/bin/*.exe" "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
# file(REMOVE_RECURSE ${EXE_FILES})

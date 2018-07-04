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

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/geogram_1.6.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://gforge.inria.fr/frs/download.php/file/37525/geogram_1.6.4.tar.gz"
    FILENAME "geogram_1.6.4.tar.gz"
    SHA512 a89b824cc7c055b7d0a5882e2f1922f09729f6eed5ed656136e8375e9b414e286fdbc5372fdb69b1ea5ce340dc81231db0228974b997be805043227de3c341b8
)
vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CURRENT_PORT_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH}/cmake)
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-cmake-config-and-install.patch
)

set(GEOGRAM_WITH_GRAPHICS OFF)
if("graphics" IN_LIST FEATURES)
    set(GEOGRAM_WITH_GRAPHICS ON)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        # PREFER_NINJA # Disable this option if project cannot be built with Ninja
        OPTIONS
            -DVORPALINE_BUILD_DYNAMIC=FALSE
            -DGEOGRAM_WITH_GRAPHICS=${GEOGRAM_WITH_GRAPHICS}
            -DGEOGRAM_LIB_ONLY=ON
            -DGEOGRAM_USE_SYSTEM_GLFW3=ON
            -DVORPALINE_PLATFORM=Win-vs-generic
            -DGEOGRAM_WITH_VORPALINE=OFF
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
    )
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        # PREFER_NINJA # Disable this option if project cannot be built with Ninja
        OPTIONS
            -DVORPALINE_BUILD_DYNAMIC=TRUE
            -DGEOGRAM_WITH_GRAPHICS=${GEOGRAM_WITH_GRAPHICS}
            -DGEOGRAM_LIB_ONLY=ON
            -DGEOGRAM_USE_SYSTEM_GLFW3=ON
            -DVORPALINE_PLATFORM=Win-vs-dynamic-generic
            -DGEOGRAM_WITH_VORPALINE=OFF
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
    )
endif()
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/geogram")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/doc/devkit/license.dox DESTINATION ${CURRENT_PACKAGES_DIR}/share/geogram)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/geogram/license.dox ${CURRENT_PACKAGES_DIR}/share/geogram/copyright)

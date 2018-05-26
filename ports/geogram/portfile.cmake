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

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/geogram_1.6.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://gforge.inria.fr/frs/download.php/file/37375/geogram_1.6.0.zip"
    FILENAME "geogram-1.6.0.zip"
    SHA512 8ae0f976338b4e47e2ef3c8cebc48e3957133131be89318df187295b813d3b45557a7dae848b42366635c3f957a63161da2302bb73e6a2af8dd745cfcc122988
)
vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CURRENT_PORT_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH}/cmake)
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-cmake-config-and-install.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        # PREFER_NINJA # Disable this option if project cannot be built with Ninja
        OPTIONS
            -DVORPALINE_BUILD_DYNAMIC=FALSE
            -DGEOGRAM_WITH_GRAPHICS=ON
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

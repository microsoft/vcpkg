# Build with 'vcpkg.exe install hyperscan:x86-windows-static-release'; Hyperscan doesn't support dynamic libraries on Windows.
#
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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hyperscan-5.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/intel/hyperscan/archive/v5.1.0.zip"
    FILENAME "v5.1.0.zip"
    SHA512 89a826c1e66175f1781f57d0d430f2d5d245ab590acc4b5df6638c5f6fe43914db028f8bc86e566ea27b55883c91be0d8da079b3d7547899f7cf540b52a3cf0a
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_find_acquire_program(PYTHON3)

# Add python3 to path
get_filename_component(PYTHON_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON_PATH})
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/hyperscan RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME hyperscan)

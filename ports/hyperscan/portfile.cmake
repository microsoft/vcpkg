# Build with 'vcpkg.exe install hyperscan:x86-windows-static-release'; Hyperscan doesn't support dynamic libraries on Windows.
include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)


set(HYPERSCAN_VERSION 5.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/intel/hyperscan/archive/v${HYPERSCAN_VERSION}.zip"
    FILENAME "v${HYPERSCAN_VERSION}.zip"
    SHA512 89a826c1e66175f1781f57d0d430f2d5d245ab590acc4b5df6638c5f6fe43914db028f8bc86e566ea27b55883c91be0d8da079b3d7547899f7cf540b52a3cf0a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${HYPERSCAN_VERSION})

vcpkg_find_acquire_program(PYTHON3)

# Add python3 to path
get_filename_component(PYTHON_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON_PATH})
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/hyperscan RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME hs)

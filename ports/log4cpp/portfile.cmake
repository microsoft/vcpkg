vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cpp/log4cpp-1.1.x%20%28new%29
    REF log4cpp-1.1
    FILENAME "log4cpp-1.1.4.tar.gz"
    SHA512 0cdbd46ccd048d70bea3c35d22080dc5dd21fc3b9c415fe464847e60775954f57e9c8344506f0f94f16e90e8bdaa9cc6d84d3aa65191501e52ee8dfc639f0398
    PATCHES
        fix_link_msvcrt.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/veigar
    HEAD_REF master
    REF ${VERSION}
    SHA512 f67f2ba3b059b734e8eaf56005dc3abd011949080591caf40a4a0f881257761e2eba9b40b1e1f3207881ab755e1ab8b4b29f17eb63e645be2c81d979fd6a87d0
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" VEIGAR_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVEIGAR_USE_STATIC_CRT:BOOL=${VEIGAR_USE_STATIC_CRT}
        -DVEIGAR_BUILD_TESTS:BOOL=OFF
        -DVEIGAR_BUILD_EXAMPLES:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

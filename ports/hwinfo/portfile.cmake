vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lfreist/hwinfo
    REF 90829612dd4b67356fd643bd9ceee44b04dc8fde
    SHA512 9f27c983d8e435c12455001cb7c2a535e9c7d94fec871a8b82d965d41f9a6e739fe4263bb18a66cf50fb826e505cbc0ff6a7c8408a3d74f783f56fefb88110cc
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" HWINFO_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" HWINFO_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DHWINFO_SHARED=${HWINFO_BUILD_SHARED}
        -DHWINFO_STATIC=${HWINFO_BUILD_STATIC}
    )
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/hwinfo"
)
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include )
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share )

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF a4dbb4b1c8a3825fc304bbbad3438dbe1840feae # v5.0.2
    SHA512 25cc9002fd46856854545934f385d8578f207b1ce01802a172e49e008cdf1db0db11db7cefeef18258b99c13570af9193e83f5826613d8b0a118d7bae3f0d03f
    HEAD_REF master
    PATCHES fix-build.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" staticCrt)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DLINK_STATIC_RUNTIME:BOOL=${staticCrt}
        -DINSTALL_LIBS:BOOL=ON
        -DBUILD_PROJECT_NAME=dimcli
        -DBUILD_TESTING=OFF
        -DINSTALL_TOOLS=OFF
        -DINSTALL_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli" RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF v6.2.0
    SHA512 173d28f8d905b423c298afbeb8709b9fe06289f71242202b9d48055b1f3415bcaccb4f1c77d60d827c49829bc6944023cd4c581f1b04a00e947daa945adc81df
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LINK_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLINK_STATIC_RUNTIME:BOOL=${LINK_STATIC_RUNTIME}
        -DINSTALL_LIBS:BOOL=ON
        -DBUILD_PROJECT_NAME=dimcli
        -DBUILD_TESTING:BOOL=OFF
)

vcpkg_cmake_install()

# Remove includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli" RENAME copyright)

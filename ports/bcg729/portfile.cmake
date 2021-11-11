vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BelledonneCommunications/bcg729
    REF 1.1.1
    SHA512 e8cc4b7486a9a29fb729ab9fd9e3c4a2155573f38cec16f5a53db3b416fc1119ea5f5a61243a8d37cb0b64580c5df1b632ff165dc7ff47421fa567dafffaacd8
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME Bcg729)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

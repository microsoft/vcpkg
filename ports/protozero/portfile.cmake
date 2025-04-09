
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/protozero
    SHA512 b5c4cef9112e03f64d53c2f15f8def28129f720f77674e8d1aac7ad663f18630bb3923495a57f94917490d27acab27f07574a6c170c9e1fb151eef702a4ffc5f
    REF "v${VERSION}"
    HEAD_REF master
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

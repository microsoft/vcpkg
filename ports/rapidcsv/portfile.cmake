vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d99kris/rapidcsv
    REF "v${VERSION}"
    SHA512 c1ca233f4705454d3cdc93265924e8bf4ce77894ce1947f958e87228c4697e304b92bf20b53c9ef6c91bcf41c18d2d045265b36b01764acd968164d75db8c054
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

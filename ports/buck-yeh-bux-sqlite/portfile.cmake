vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-sqlite
    REF "${VERSION}"
    SHA512 9b2bc78bf803381d481a84c430e557126e014ed43343d8f6b12791b41dcf88e741883efb1aa7cba624c0a42a99782501f355baa465de2df90bffaf425d1aa337
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

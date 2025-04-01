vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF "${VERSION}"
    SHA512 9006ff5e6000f3330d9db05d450137f479c43cd2d3a730a66bbf0e7b9f337dd957cf34631d5623768fd064a696bce0e1c303c3fa7ded401bd2cc85c3e4944f70
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/ranges
    REF 571cd41f36f25640b8ef9cb3ccb821a4402b3c6d
    SHA512 34744d4f3bcda06ba037bb7053d6e0b4326582539984936cbf49563fc4742bd57879ff27d15254a3cddbe28854269e832c0b8fbbc0d1b98c2496df1081153f3e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRANGES_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
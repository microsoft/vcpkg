vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 bcae6a0d1882196d5677248800b296164ffa3fc64d768c0bede43290a11315923e46617508822a8aad9b15eee84c46cf8b38836a8bd86b7cc32dd4d40c020a8a
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/lzav")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

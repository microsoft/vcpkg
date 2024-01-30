vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d99kris/rapidcsv
    REF v8.64
    SHA512 37424fda3b706a1ba3c29d836f240b0a2c3335095da629cfe79bb58a78fc7d8b172e0309447e9ec75f7dd21925a55b5ca96b673a9fff36f0078b948330a42801
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

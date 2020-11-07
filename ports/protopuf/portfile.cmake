vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PragmaTwice/protopuf
    REF v1.0.0
    SHA512 d392846e2ee1c6e8f7a6698e4baaaa9b1882b78b5f382c1fd8d7bc67864d4d2eb98448dc071f31fca2e640c148bb3948b2330a7d119f498930f2c41a5df5e4f2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protopuf RENAME copyright)

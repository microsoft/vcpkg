vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PragmaTwice/protopuf
    REF v1.0.0
    SHA512 45644fd586da80a7bb9e434152f2b28b99d45f5679b9fcc173ff3f1abf42d8deb971641351cf67dc3408a86da25ed03154fe612f56983282da32dc3e29333f6c
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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

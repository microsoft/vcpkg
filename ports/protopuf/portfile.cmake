vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PragmaTwice/protopuf
    REF v1.0.1
    SHA512 d58bff752fde243ea20c4bcb34c197d6495004b6a77a95332aff3d4a647adf5e1a6fb3cde862aa7e876b02ad0caa4893f2337323dca510686c7a95c1598d2249
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

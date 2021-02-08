vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ikalnytskyi/termcolor
    REF v1.0.1
    SHA512 15deaa7d225fa7934c207e6a57d89fd4c0ea5ebef38c4ff58ff27e19f444b030c265406a525f545592d67cff2b24ed839992693bb6d043cb3d8bca986c53fd95
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${port}/ TARGET_PATH share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

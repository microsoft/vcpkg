vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF v1.1.1
    SHA512 687531634ec827f6f34c694b8daf94ed9ff02b1d5b63d191e70b77a201f5582142718ad89d315a40bb72ab3707f237772c1838098e219e7a2db46d90718d5c4b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

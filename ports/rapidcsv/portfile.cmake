vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d99kris/rapidcsv
    REF "v${VERSION}"
    SHA512 721e82306315481dbec88a1c150568d038ab57f50dd2d8fd13bfe66cc55f62bedcca1392610ff678ef06fa7908a876a6d38a8fb7afd5c17f2b3d1b3a57661d26
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

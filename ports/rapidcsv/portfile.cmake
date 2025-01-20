vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d99kris/rapidcsv
    REF "v${VERSION}"
    SHA512 8fb03ad7e3b53f01c568deb7705a7185a66cfc1eb0245b0165d580a8f60a8972197cd5eac3cda115d9bbb3c06c89de25a84acad62d13d6ffb366d3f1155a1b9c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF 00d552f22e77ce3f6a57f0eeb6cbae48e57f5066
    SHA512 0ed0ae96a4856ea354ead4a3aa17a8d390dec50f0b19eb1b81506d7e6dd5cbedbca9bb77b64240b7a50ab7746af7b461793018e0a956d6813b15e0929f041466
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

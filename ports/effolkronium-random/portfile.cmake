vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO effolkronium/random
    REF "v${VERSION}"
    SHA512 778667d3b3a4bd51b67ef7d1842652dcf6d7df210345f667d0474cdfe48bb75fa2c891f8843f3fc4946fb2ef71da652c296eaaa03718ed889dee4926d743b7dd
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRandom_BuildTests=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME effolkronium_random CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
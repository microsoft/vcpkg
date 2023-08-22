vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraillt/bitsery
    REF "v${VERSION}"
    SHA512 6edaf4d5f22d640df67813f7525c2e076a76911079e25eeb93f4302a835b26d986379d1aad6bdb98f1781af3a5d638ee02ea9c32765741ce91366b518fc4d447
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

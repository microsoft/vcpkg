vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             9eb884a22da8f8ef0a1018a1cf03da3cfe991c0a
    SHA512          634cfe31ea2bb227e25ad23c77ef0801f3b0b8a46f75fa0125dbea798261b44286311a04c0177ad689d5f064533e84b797e0075e0a82a9d9b022887125ad68bd
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

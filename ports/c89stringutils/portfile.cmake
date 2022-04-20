vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             efa52aa513090d8569adcfc8b8f05eec027ee8ef
    SHA512          0139fad109b0ab20b2c0447d7bedcadf19d05c5890551563dd8c6cd657ab1c40c0ae046451135a5694df94b3a89b93a65dc4b57ae94667c9bcf62f0b04d9b1e6
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

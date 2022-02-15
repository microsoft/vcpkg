vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             aec6f0f0d2cafc9d9bc049701770c09ac6cd6a78
    SHA512          c1b85adf91baf34373b7bbd907161cc4839c70b07f3219b510dc3ce3fceeddd325f81a0d1d633ffb4d46a49775869eeeddc47e9a84dff640251d90bdd61b54c1
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_CLI=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

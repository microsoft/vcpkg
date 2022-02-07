vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             06a2cce2b69c3ccdc3d184d0b3b0c3a001a906ab
    SHA512          1d5a8f76a174cca8ed072194de6c268c22f6428f450bd45edc964fdc1c802b5a70e1cf0b7ed85691ba67f1a9d921bac3a94c68c8ed34be87cd350150beaa0b7d
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

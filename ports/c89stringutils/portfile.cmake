vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             9e579b122af0e69b197ba8f0f123004897806c7b
    SHA512          b453115ff32477a60d3556f7295079a05c142d5ed70fc36973ef9e45e1d0c57b819712425f718a35c471dd4e65108c6d3a79e51969cb3ca36863ea6d215d5243
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/c89stringutils"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

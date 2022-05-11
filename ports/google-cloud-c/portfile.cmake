vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             4a1d7e4dc09848ef2bf228a6dd4e0e11ece3c797
    SHA512          78bc9dbd5802604bbd35c0a3b7ecf8899a6902d4bfbd2c3f423513ab6b808c8eac2659d25ffc1c86f43e7790052e87da60c7589f45dd470eafaee44ee8735d90
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

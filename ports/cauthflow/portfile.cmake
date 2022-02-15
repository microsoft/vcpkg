vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             1d5afae65deb3bcb5bec9b426b48bfa3179430c8
    SHA512          29e7533439c294793f161cf1e1dd0244f87e7be7b1aef84381b9ff790536dd2145143d420d119ac21e01bf54b6fac1d64706d88aaafa697b2ad703ee71fded94
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

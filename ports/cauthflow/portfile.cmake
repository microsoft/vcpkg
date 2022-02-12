vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             593944495a3433596cbe7f180e8576931b6c05e3
    SHA512          dbaa6cbfd6c6dba7f4d51ab6de67697bea2e864c92923d4f768723e4372ea6448bf12a9c2f903c61c40e159e076eadd6a449cfa6f185136837bee915cd13e256
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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             ad0bc2359696dab6f82cbf274c7d2a52c6f68060
    SHA512          968b42500ec88fbf5f7a89fe35cd1887ef81277b2ce28b747638b2f50d8c1a7f620366f7b6a6a819f8aab7785fa01c26c8a99367899840e6af8ec5a8f25f9431
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

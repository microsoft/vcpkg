vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             a95355191cc42292e54a91b15657c5c129a73b89
    SHA512          49f821f9fb96d7fcaceba98cb75bf97153a59463d7aa8b9fd3e6122a243c9aa632ea8d8c06bdb4dcec4aa4713c6fb80d28621e05ddab79b6883c6058b573f642
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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             5a9829c7b7fc18fc963bec1661a7f6d66c91d30d
    SHA512          72eb1c1a4239101c88928f95e538530f391bab7cde985cca187a22e3741d195444b69fb9f295f383199294ef2aff669ffa1488a125abe41497d0e9efedd673ca
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

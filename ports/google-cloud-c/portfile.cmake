vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             a2ce8cca0f229b07f23536c1b139ed2a328e5a54
    SHA512          7f0c60c23a739ccd6d80e52d9cb05d143b51f80aada13cb37115898ef191fccc1926cf808a61dee2aa361b1f0b57f590f40d0beb1fe95fff772bd75933f63de3
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

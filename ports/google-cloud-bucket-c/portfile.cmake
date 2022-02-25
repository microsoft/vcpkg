vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             57fb78277998e80b86b0218e6b12a07cb6c83548
    SHA512          00c62a2031fa1a8e4e1992842e512ff4672819df8a9842329c2943159b037e27419be1a078a5828d7998ea4cc118f6f462d6b9edc438b5ad77be17aa6c4d250e
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

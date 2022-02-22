vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             d1662e3e6cf64e063c1836e0a2ba20e885851aff
    SHA512          a940491a1590e61585c52815610a6bcb8ec2b41a8f6a270cf33b09b2053ee9bc8bb207a4b3bf02c24aecb51ae9bddf7cb5a29be427aeb69dcfafd6a68e06e235
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

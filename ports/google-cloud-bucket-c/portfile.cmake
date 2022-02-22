vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             611bef746802403ac3082e9c627e77e992eecdad
    SHA512          b0cfaf5c09b79807ab1f511698cede86265d1056232c9fc4396e55b463eed4f1557641aa60a442a9a4d2296c821bc38762bae011589d243682eb36a2b239f15a
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

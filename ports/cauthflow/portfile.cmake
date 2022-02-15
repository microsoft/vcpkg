vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             6f9e90eb2681fa8962bfb35fe64db0eb970e1eb4
    SHA512          89090017ca00e0588ca777404fe4c467c44846a31785a0f699797dd9b6f271474a1dd8e2871d7c92fee56ed059fa593a0f6d581485428f1d43218dd3d39f18a7
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

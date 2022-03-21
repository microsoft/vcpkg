vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             beb8435ccb8bc548ce37964414f44de30cd63665
    SHA512          2d3fe54dde449d009ac67190d788c8bc233f36166315da3f6ee0718ec45d328e3f4683cf6a27b518232463ba9efc87bbce403d242aff6d0bab6a562ac4f775e3
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

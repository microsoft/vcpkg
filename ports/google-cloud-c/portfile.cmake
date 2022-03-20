vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             c185bb4dc33c3c46d2d34118f7d190b675fa7f2b
    SHA512          461a57fb4b91daea0e81e7b8c71ae14003ab33a317dcec56960ae5071431bd8b354f4e077cd67f5e562e4055f9c17e89e608de061786771bce56ca3def10e706
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

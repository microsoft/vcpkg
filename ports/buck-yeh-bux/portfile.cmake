vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF b046518dcffcdef9b8dbccd0accc2636df301766 # v1.6.6
    SHA512 af1ca5c37623a09c64e1a84a630a26911be8c87eb007b112665b7c6080dfac67bd89eb36367202c5d29af97f4e549d6f27e41410220a57bd7756bdb1ecf8ddf0
    HEAD_REF main
    PATCHES fix-clang-cl.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

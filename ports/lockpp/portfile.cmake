vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Soundux/lockpp
    REF v1.0.2
    SHA512 6d92d3bbcbad3e2afd844ab95526e1eb49a7722d0d9d972ff85df561bbb9dc0b7a8aa5c83847f6832a806e52dde427ec0bcd11570b095d9cce7e35b3717e1f51
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

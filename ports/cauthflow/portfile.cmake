vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             38b22a8374cf2498b6906925340ef22a28f2aa71
    SHA512          40d06db95391028df46a3c0f19562f3b210b4e79d3c4e71ab2b877c45f025c55f58d6bd6bf7faad178e2c069a8cb3e1c5da1cb58152ead108439475a779ae368
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

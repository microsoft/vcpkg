vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             094c28cf2de1866000477ed80fe797ed42fb9be9
    SHA512          e9567505b572ab6b2af5c25e04cdbad117183d6ed4c18f3d618f94e3345751d2381f7b1bbffda4dbcb4923a4f1386febf57e2d68af2d250ee4f395abea16300e
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

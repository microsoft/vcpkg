vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/fswatch
    REF             99d52cb74d21e7f09edbcf9b0d0103448f01fd84
    SHA512          3e97f8bb28352991315916293a0854e3d74b2c473cffe02075c2a0efdb479d56bac02c3e9742bfc9d59a1b43ab4bff69d212cb366c6dc549462a33390618e565
    HEAD_REF        multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_FSWATCH=OFF"
        "-DBUILD_TESTS=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


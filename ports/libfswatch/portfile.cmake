vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/fswatch
    REF 6b273e1285cfb6cf6df3fbd4d593a07500184559
    SHA512 4e13465fb2f51e68e3a37bc894415b3f1474144e12aad00e9c351ede04ad3ed5d58a2988c44d94a5589ec88373f6d80b7367c7b62c00e6f230c71a1f63fa064f
    HEAD_REF multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/libfswatch"
     RENAME copyright)

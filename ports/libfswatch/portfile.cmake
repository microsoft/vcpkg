vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/fswatch
    REF 025ec52c92d10da6dd8e3ff6972165384ea4f04f
    SHA512 60b34236b1dcc09250ff6f486614aaf659d35dd787c251d9d84d03c3fb2d317e15bbc4d38325c213d78dfe5241d8c69b4238681f9e3eca2d15be12d9933b2470
    HEAD_REF multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/libfswatch"
     RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             eae57cd0cfec9eda9c66e1dd5eade307f5e9df20
    SHA512          8c1b400ea67617717cce14081a3d3d180c9648bb9097dcef14530c67f58d9fc3abd3a4057f8925c812889affcade9f16bee178431c6afb847dbcc7516aebbebc
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

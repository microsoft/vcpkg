vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/${PORT}
    REF             b30f175ced89adb4db35a457ea5649533ceb2bee
    SHA512          cbd29cc9d7555279ca88e7748a07629493e89c874696f9feac1707c3e4f0caa7efdf0bc6f4389bbf5dd3790fb1a500de35df6fb81c8867ec2d2d820d3f5603b6
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

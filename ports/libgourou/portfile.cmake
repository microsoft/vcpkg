vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/${PORT}
    REF             c48e74dfd13f6db12c4330ba13f67bab3d099100
    SHA512          296aab36da82930c27f39d813b06051d01fae99e35ede2c8ca91dc2ac291964f89f184ffda03f34f113624a343118bf462071d9f9f9ed5491a12eff7facca627
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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             53a361ce7954c07252894f27d38d902828a1753d
    SHA512          f1edf09f32a4cb57a0fb267929b3ae6aeb3aa00f095722d33bde0ad4d88e2dd70b92fa68a577bbd64114986177d5b45fbb554e8f10f427fde0011593e185ee43
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
foreach(_dir "include" "share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/${_dir}")
endforeach(_dir "include" "share")

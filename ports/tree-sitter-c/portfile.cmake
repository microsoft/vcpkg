vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "SamuelMarks/${PORT}"
    REF             bf97c9482e90af607ff76346e14d4626aba0f1f9
    SHA512          779f2eb4e57cab5fc26ed272af8e2a0249f4a683c7ee1ca929bacec0f925cd923e2a339423c1975b1c2081639cb9326f6760c163c94af1e4fc5d776712614aa9
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

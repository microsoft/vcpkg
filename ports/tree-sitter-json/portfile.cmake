vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "SamuelMarks/${PORT}"
    REF             1a95fb5354d96dcdda56303f4ce131dd161375ac
    SHA512          c16e3d4f43557e4fa40c042f799575a9da3cc0ab0e1f919885d1df18b7f4b8541cb06ac9a02d092177665adc2764b8544551b4329d3ac91e851cd3630297cba0
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

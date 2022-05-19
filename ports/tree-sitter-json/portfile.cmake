vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "SamuelMarks/${PORT}"
    REF             a67fcad08d644588aaf2312fa9f6e69db2020f4e
    SHA512          9876946b9e8e6b6c7db6ee098148d7fc06d4de30994d62ee958d0ebfca0d809f5d198d031d4ebe2c17bf583e9606d0cf28764322b023557746d54a4b060aea4e
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

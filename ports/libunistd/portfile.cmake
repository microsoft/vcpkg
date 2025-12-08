vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/libunistd
    REF             8ab9bd613b15302e767003ff1841acfad5d8ac97
    SHA512          802fde13d16ba17a221121fca3c63d2829b65f54a382428f385f273a5978162e61b412a872e1a3c2ddc69094fb23f39422e365357706ccd62b592fbb5da62ba2
    HEAD_REF        branch-opt
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_TESTS=OFF
        -DBUILD_SQLITE=OFF
        -DBUILD_UUID=OFF
        -DBUILD_REGEX=OFF
        -DBUILD_XXHASH=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

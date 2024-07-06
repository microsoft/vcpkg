vcpkg_download_distfile(ARCHIVE
    URLS "http://users.ics.forth.gr/~lourakis/levmar/levmar-2.6.tgz"
    FILENAME "levmar-2.6.tgz"
    SHA512 5b4c64b63be9b29d6ad2df435af86cd2c2e3216313378561a670ac6a392a51bbf1951e96c6b1afb77c570f23dd8e194017808e46929fec2d8d9a7fe6cf37022b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES add-install.patch # patch just adding the install commands to original CMakeLists.txt
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DHAVE_LAPACK=OFF
        -DHAVE_PLASMA=OFF
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Handle duplicated debug includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

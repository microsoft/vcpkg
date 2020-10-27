set(OATPP_VERSION "1.2.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KaungZawHtet/oatpp-sqlite
    REF b69459eb0c0c1482d4484ec2915c5df55504c634 # 1.2.0
    SHA512 9949f05c2e16eb4a7d776a93756228dda0e8ae0a17ada6fd167818915b46f526aa3ba77d3899b7843f775f72c05faa813c466980432c5089dae8686524f29308
    HEAD_REF experimental
)


vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
        "-DOATPP_SQLITE_AMALGAMATION:BOOL=OFF"
        
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-sqlite-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

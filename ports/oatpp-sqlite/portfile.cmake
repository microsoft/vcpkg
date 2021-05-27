set(OATPP_VERSION "1.2.5")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-sqlite
    REF ${OATPP_VERSION}
    SHA512 b92d8c8b2afbbca38ecef7030648dcd7e15d7b2dd221bc32ea9778533ffcc9923b628308aa86bc53451b1ea4bb15dae8727bc6e0d8345fa611ef32469d850064
    HEAD_REF master
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

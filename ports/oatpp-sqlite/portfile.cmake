set(OATPP_VERSION "1.2.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KaungZawHtet/oatpp-sqlite
    REF 4b3721f1555182117dec446d3121a56d9985b434 # 1.2.0
    SHA512 fed081c362c86689fbb751d6607059ef1f503ed64f4c695d9077e85007969e70e52dc511b21be82b741d323c4cb782f58d0c4c459040c122ac43e4fdcff50d2d
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

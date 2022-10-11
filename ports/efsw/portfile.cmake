vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/efsw
    REF b62d04829bb0a6f3cacc7859e0b046a3c053bc50
    SHA512 fc16ef6ad330941dc0a1112ce645b57bd126d353556d50f45fadf150f25edd42c1d4946bc54d629d94c208d67d4ce17dbf5d1079cbeed51f0f6b1ccbe2199132
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVERBOSE=OFF
        -DBUILD_TEST_APP=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/efsw)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

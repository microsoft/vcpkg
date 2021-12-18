vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oliora/ppconsul
    REF 8aed30cae0e2df76d920b5cd77933604a4644ee9
    SHA512 756f07c7c8099868fa181571941f511987088abc110ad5eda517ad591ed10b40532cd7b1541dbdad76c2617ce804a1dc26a121380f20f8e4a40e29063523cbbd
    HEAD_REF master
    PATCHES "cmake_build.patch"
)

# Force the use of the vcpkg installed versions
file(REMOVE_RECURSE ${SOURCE_PATH}/ext/json11)
file(REMOVE_RECURSE ${SOURCE_PATH}/ext/catch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)


file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

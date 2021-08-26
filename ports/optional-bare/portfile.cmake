vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/optional-bare
    REF v1.1.0
    SHA512 0eed103c4e909991b596c0cd23d6206662e3ca71cd8148e27c19d8e071c2a16e18cc940a6cd4f8571510f5e64577157f94c561fb889330bb7a868af64c2f3aa0
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPTIONAL_BARE_OPT_BUILD_TESTS=OFF
        -DOPTIONAL_BARE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)

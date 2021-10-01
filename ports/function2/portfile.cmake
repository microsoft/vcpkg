vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Naios/function2
    REF 02ca99831de59c7c3a4b834789260253cace0ced # 4.2.0
    SHA512 5b14d95584586c7365119f5171c86c7556ce402ae3c5db09e4e54e1225fc71e40f88ab77188986ecf9dac5eecbfd6330c5a7ecfe0375cb37773d007ebef1ba93
    HEAD_REF master
    PATCHES
        disable-testing.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE ${CURRENT_PACKAGES_DIR}/Readme.md)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Put the installed licence file where vcpkg expects it
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

vcpkg_copy_pdbs()

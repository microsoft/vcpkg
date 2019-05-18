include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO json-c/json-c
    REF 3e81b4abe359c8128bb2b4127f4e8c8c057fb004
    SHA512 a2cd6d71d72d0dcacf2056466f3f414df180aacc9c2ee93b85f047683a88671590089535d7cecf71ef1bf0844b5ab35535e64022854d2fbc7f82d889aefcd730
    HEAD_REF master
    PATCHES
        export-cmake-module.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

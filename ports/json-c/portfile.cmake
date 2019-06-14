include(vcpkg_common_functions)

# https://github.com/json-c/json-c/issues/488
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO json-c/json-c
    REF 2b1903cc6941fb87db7526680829486f27fb1073
    SHA512 0ee71a0c2f75f5114b65f06ef921ac7a66173d66592fa880336896de64f3a325b251028b35396184cd7c3ffd15db3826bed83200fa80f4d11607fdf758138bf9
    HEAD_REF master
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

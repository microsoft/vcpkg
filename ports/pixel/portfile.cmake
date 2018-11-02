include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dascandy/pixel
    REF 0.1
    SHA512 023b084450ef86f73488f9add2a91a7902591d1614f22958ded8c5b0458e71dd710cef73dd7cc1563e35b02770cf0baf94f2ce40532c7119ce90f0178543efca
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

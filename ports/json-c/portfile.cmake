vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO json-c/json-c
    REF eae040a84a479ccad1d1c48314345c51ecf1a4a4
    SHA512 18d8a31b341830b04676cad13fbc0608fb75a323522161ac8fd0bb5058db82c1c261d504696a1e12f4b03eb0967632885580ff81d808adf2f1dff7e32d131ba0
    HEAD_REF master
    PATCHES pkgconfig.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

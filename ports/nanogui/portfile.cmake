vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mitsuba-renderer/nanogui
    REF 0146a88b2214cd5c5c29e6dfa8d3d3d0e9ab6d9d # Commits on Oct 16, 2020
    SHA512 0b0d0d077079e1a7186ec2cc640dbd48aebcefa0e1e0caa476128c6396b33d236cb5e8aaada4e1c8868a5d4aaefd90178206dd1569abab63c84af26d3309e2a5
    HEAD_REF master
#    PATCHES
#        fix-cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DNANOGUI_EIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
        -DEIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

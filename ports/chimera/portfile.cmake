vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# checkout hyperscan source code which is required by and also contains chimera
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hyperscan
    REF c00683d73916e39f01b0d418f686c8b5c379159c
    SHA512 3c4d52706901acc9ef4c3d12b0e5b2956f4e6bce13f6828a4ba3b736c05ffacb1d733ef9c226988ca80220584525f9cb6dcfe4914ced6cc34ae6a0a45975afb5
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        fix-unix-build.patch
        fix-include-path.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/chimera
    PREFER_NINJA
    OPTIONS
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()

# remove debug dir
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

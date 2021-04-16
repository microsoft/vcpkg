vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "UWP")

# NASM is required to build AOM
vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

# Perl is required to build AOM
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://aomedia.googlesource.com/aom"
    REF 307ce06ed82d93885ee8ed53e152c9268ac0d98d
    PATCHES
        aom-rename-static.diff
        aom-install.diff
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_DOCS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_TESTDATA=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_TOOLS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Move cmake configs
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/aom)

# Remove duplicate files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

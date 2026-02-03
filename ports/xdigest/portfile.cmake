vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rinrab/xdigest
    REF "${VERSION}"
    SHA512 9bb3ceaca9a3cf35b5dd562589158dc50ad3692c3d17d4b39e1f4a36a00861e30913de5ae3052836deb3ef76a45ad69c7822e2fb14a27c6d73dfcd6115a76d15
    HEAD_REF trunk
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asm USE_ASM
)

if (VCPKG_TARGET_IS_WINDOWS AND USE_ASM)
    vcpkg_find_acquire_program(NASM)
    list(APPEND OPTIONS "-DCMAKE_ASM_NASM_COMPILER=${NASM}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        ${FEATURE_OPTIONS}
        ${OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/xdigest")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

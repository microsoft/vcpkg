vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rinrab/xdigest
    REF "${VERSION}"
    SHA512 0b5a6c2dae2e7fbd1b731ef6237ef8fd8bc437f12067cec8d12fb47c8f09df2879d10cad8a1a9c5c9a9885b9d046d19174b0333cf3ea81e8073eb1fac50014a9
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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rinrab/xdigest
    REF "${VERSION}"
    SHA512 2a98b29ceaf1d17e9251c1486d03a2d3db133a29fede730ebdf1cb84987aa50781e56ce1db2d795f6dff84b755720b91aa866da662699d34d8a9d140adc8d04e
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

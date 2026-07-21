vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bbalouki/itchcpp
    REF "v${VERSION}"
    SHA512 0a09c885ca786d2904bec4ef886ab104afa3a98fb39be9db2fd1ef553767c964cfe4cc894b6e74273379eb08f785e9dceb7e106e86aa885bbe19e24fd8c7869c
    HEAD_REF main
    PATCHES
        fix-package-install.patch
        install-python-bindings.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        arrow ITCH_WITH_ARROW
        python ITCH_BUILD_PYTHON
)

set(PYTHON_OPTIONS)
if("python" IN_LIST FEATURES)
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    list(APPEND PYTHON_OPTIONS
        "-DPython_EXECUTABLE=${PYTHON3}"
        "-DITCH_PYTHON_INSTALL_DIR=${PYTHON3_SITE}/itchcpp"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${PYTHON_OPTIONS}
        -DITCH_BUILD_TESTS=OFF
        -DITCH_BUILD_BENCHMARKS=OFF
        -DITCH_BUILD_EXAMPLES=OFF
        -DITCH_BUILD_FUZZERS=OFF
        -DITCH_BUILD_TOOLS=OFF
        -DITCH_BUILD_DOCUMENTATION=OFF
        -DITCH_ADD_COVERAGE_ANALYSIS=OFF
        -DITCH_APPLY_FORMATING=OFF
        -DITCH_APPLY_CLANG_TIDY_GLOBALY=OFF
        -DITCH_ENABLE_ADDRESS_SANITIZER=OFF
        -DITCH_PROJECT_ENV=PROD
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "itch"
    CONFIG_PATH "lib/cmake/itch"
   
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

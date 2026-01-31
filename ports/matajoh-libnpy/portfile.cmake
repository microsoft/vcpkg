vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matajoh/libnpy
    REF "v${VERSION}"
    SHA512 808e76d341ca4abc88b9cd8d354ce9e77799c1d8d20654d2a38aa9ffca8ffbb8e64de5100c815a23f8db9432ad3e9d411af08d30fdce87f474740460080f4781
    HEAD_REF main
    PATCHES
        fix-install.patch
        fix-miniz.patch
        fix-zip-wrapper.patch
        fix-npy-config.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/miniz")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBNPY_BUILD_TESTS=OFF
        -DLIBNPY_BUILD_SAMPLES=OFF
        -DLIBNPY_BUILD_DOCUMENTATION=OFF
        -DLIBNPY_INCLUDE_CSHARP=OFF # when swig is added, this can be added as a feature
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "npy/cmake" PACKAGE_NAME "npy")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/npy"
    "${CURRENT_PACKAGES_DIR}/npy"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

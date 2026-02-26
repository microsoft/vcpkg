vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matajoh/libnpy
    REF "v${VERSION}"
    SHA512 6fece3d931f0beba2f5bd7563c24f451f8480a479081b319182d514a50dffc2224e23b76f8e6f35b51847adb214b900e4eb5f5a4d4de429cae196d5e49573486
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

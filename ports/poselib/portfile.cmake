if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PoseLib/PoseLib
    REF "v${VERSION}"
    SHA512 ed56d8cd6a3073776edbfe9d11e2ebf8e2bed4065f7f53a02541323c1631632bf6c161d305fc09674175351b024bf019211dfa9d7a48e74e3c5563941099f1ef
    HEAD_REF master
    PATCHES
        fatal-errors.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMARCH_NATIVE=OFF
        -DWITH_BENCHMARK=OFF
        -DPYTHON_PACKAGE=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PoseLib)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

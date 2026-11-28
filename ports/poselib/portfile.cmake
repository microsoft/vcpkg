if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PoseLib/PoseLib
    REF 6a636b1d84273d5e3ba97676463476569611572a
    SHA512 64913141f0d1f268440266bed89927fddc34bdfbff285c05422970556e281acfc973157850e21340d8df1ddeacd23cfab1649030cf561427725c20ef3c9497ec
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMARCH_NATIVE=OFF
        -DWERROR=OFF
        -DWITH_BENCHMARK=OFF
        -DPYTHON_PACKAGE=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PoseLib)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gelldur/EventBus
    REF master
    SHA512 68be92be9a1adc37498e24850ae87384a34ed0343f29a5e525c984f5e220dd721b506fdd7f627e369300c07300f5fff06d88991f69c1e9bc0fff0d2a5b8f0eba
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
    -DENABLE_TEST=OFF 
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/eventbus)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

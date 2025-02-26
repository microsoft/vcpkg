if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AngusJohnson/Clipper2
    REF "Clipper2_${VERSION}"
    SHA512 0d885c5e38906fdc64c915a1cabbd37dc3d752d8c8988100f5f9af79234c3634254c0f61e931cc8bb0cec1f3404aba63be61e6cfcb00b177a3d75c415680fbd2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/CPP"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCLIPPER2_EXAMPLES=OFF
        -DCLIPPER2_TESTS=OFF
        -DCLIPPER2_UTILS=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

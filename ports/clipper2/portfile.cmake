if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AngusJohnson/Clipper2
    REF "Clipper2_${VERSION}"
    SHA512 91036e81244f3615095d7cd8522f9c4a32ea66f802e3d190393eb8939e1a706b69c69c3a5b7c6522235c075dd6ecd45f21bffb47448ba72191ddcf05e9e93128
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

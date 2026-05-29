vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO billyquith/ponder
    REF 3.0.0
    SHA512 b6ba1ce9fa0584b16085c56afb70e31f204a66b57193c1a4225bfe18abbda561bb71b3279dd0a4f1b21867b985ef5ce78c8e360f3fc654c61ce61c44d35c5f38
    HEAD_REF master
    PATCHES
        no-install-unused.patch
        github-121.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DUSES_RAPIDJSON=OFF
        -DUSES_RAPIDXML=OFF
        -DBUILD_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/${PORT}/cmake)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/${PORT}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/config.hpp" "ifndef PONDER_STATIC" "if 0 //ifndef PONDER_STATIC")
endif()

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)



if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v3.1.0
    SHA512 49e5339263190a6ef15284ef2dcc9e727ce0659cb750d4078024ccf6c6f339740a3a662273718ea73adfbc5928c3ef7268175ebda5ee9ec97ca58fed98747b44
    HEAD_REF devel
    PATCHES
        fix-install-path.patch
        fix-uwp-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCATCH_INSTALL_DOCS=OFF
        -DCMAKE_CXX_STANDARD=17
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Catch2)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# We remove these folders because they are empty and cause warnings on the library installation
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/benchmark/internal")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/generators/internal")

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch_all.hpp>")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

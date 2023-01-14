vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zxing-cpp/zxing-cpp
    REF v2.0.0
    SHA512 fa22164f834a42194eafd0d3e9c09d953233c69843ac6e79c8d6513314be28d8082382b436c379368e687e0eed05cb5e566d2893ec6eb29233a36643904ae083
    HEAD_REF master
)

if (VCPKG_TARGET_IS_UWP)
   set(ENV{CL} "$ENV{CL} -wd4996")
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BLACKBOX_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SYSTEM_DEPS=ALWAYS
    MAYBE_UNUSED_VARIABLES
        # Currently no dependencies, but this defends against future additions
        BUILD_SYSTEM_DEPS
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/ZXing
    PACKAGE_NAME ZXing
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nu-book-zxing-cpp" RENAME copyright)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nu-book/zxing-cpp
    REF v1.3.0
    SHA512 27821667dea3d09b91bf9825ff25483ed658d850fd238009f1c7e43b1b09e62d24b3a2cd78d4e39d29725931b32bfce3e21e7ec871830b3ad69a5a69c72d8de8
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

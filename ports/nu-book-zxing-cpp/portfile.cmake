vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nu-book/zxing-cpp
    REF v1.2.0
    SHA512 e61b4e44ccaf0871b5d8badf9ce0a81576f55e5d6a9458907b9b599a66227adceabb8d51a0c47b32319d8aeff93e758b4785d3bd0440375247471d95999de487
    HEAD_REF master
    PATCHES ignore-pdb-install-symbols-in-lib.patch
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

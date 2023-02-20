vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookexperimental/libunifex
    REF 591ec09e7d51858ad05be979d4034574215f5971
    SHA512 b07ebad2e6fa9a40c73fe2712e65cfe49591857bf784bd901acb7f35549746a36679c969df89321866530fd774bde176aa2d800f3da1462e818eecb8d0822842
    HEAD_REF master
    PATCHES
        fix-compile-error.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test    BUILD_TESTING
        test    UNIFEX_BUILD_EXAMPLES
        coroutines CXX_COROUTINES_HAVE_COROUTINES
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_CXX_STANDARD:STRING=20
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unifex CONFIG_PATH lib/cmake/unifex)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/unifex/config.hpp.in"
)
if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/unifex/linux")
elseif(VCPKG_TARGET_IS_LINUX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/unifex/win32")
endif()

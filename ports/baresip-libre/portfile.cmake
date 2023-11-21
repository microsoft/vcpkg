if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Workaround https://developercommunity.visualstudio.com/t/Missing-threadsh-in-MSVC-178/10514752
vcpkg_download_distfile(HAVE_THREADS_PATCH
    URLS https://github.com/baresip/re/commit/ebdf9d724cfd0a04f194ecfcb678b702ad062be2.patch?full_desc=true
    FILENAME baresip-libre-ebdf9d724cfd0a04f194ecfcb678b702ad062be2.patch
    SHA512 2ed0361cef8d599c3369ba9d2b077781484666be2f5fe172301e727d1653060a8980dfe3e4d340d0f09c92470d677200f963442eb90f9efc429c15ccf75ac353
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baresip/re
    REF "v${VERSION}"
    SHA512 59988a665db0682bb8a4dd8dc720f0ed80f49f5148aa02f175dfa01b051b9637db89b6f7343bc0544eba9adb7f0d69e0755b99ecaf4cf7eb303d90d1625c9e11
    HEAD_REF main
    PATCHES
        fix-static-library-build.patch
        "${HAVE_THREADS_PATCH}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBRE_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBRE_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBRE_BUILD_SHARED=${LIBRE_BUILD_SHARED}
        -DLIBRE_BUILD_STATIC=${LIBRE_BUILD_STATIC}
        -DCMAKE_DISABLE_FIND_PACKAGE_Backtrace=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME libre CONFIG_PATH lib/cmake/libre)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

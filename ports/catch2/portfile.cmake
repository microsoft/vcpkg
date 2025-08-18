if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v${VERSION}
    SHA512 bd349f7d2bda67213adb15f858d688591b4c526d31db09d5250358b95d636b347eb99a6600174df75cf5b71058d63db700f5af736fd1d3d1ebda12fadc43bc53
    HEAD_REF devel
    PATCHES
        fix-install-path.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        thread-safe-assertions CATCH_CONFIG_EXPERIMENTAL_THREAD_SAFE_ASSERTIONS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DCATCH_INSTALL_DOCS=OFF
        -DCMAKE_CXX_STANDARD=17
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Catch2)
vcpkg_fixup_pkgconfig()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/catch2-with-main.pc" [["-L${libdir}"]] [["-L${libdir}/manual-link"]])
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/catch2-with-main.pc" [["-L${libdir}"]] [["-L${libdir}/manual-link"]])
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# We remove these folders because they are empty and cause warnings on the library installation
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/benchmark/internal")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/generators/internal")

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch_all.hpp>")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

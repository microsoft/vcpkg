vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nilstate/icey
    REF ${VERSION}
    SHA512 fc1bde42a1d7c05fff029595b973582a5e992a9f15fa9e04e68a51fa0efb00be954c9174db9dd2badd70636c0f715d0d5c1f3b5ced9f0c1b39363cbf4c9bff3a
    HEAD_REF main
    PATCHES
        fix-minizip-config.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ffmpeg   WITH_FFMPEG
        opencv   WITH_OPENCV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_SYSTEM_DEPS=ON
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_APPLICATIONS=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_ALPHA=OFF
        -DWITH_LIBDATACHANNEL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE
        -DVCPKG_LOCK_FIND_PACKAGE_minizip=ON
        -DENABLE_NATIVE_ARCH=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/icey)
# The tagged source omits the Windows Debug postfix from pkg-config metadata.
if(VCPKG_TARGET_IS_WINDOWS AND (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug"))
    set(debug_pkgconfig "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/icey.pc")
    file(READ "${debug_pkgconfig}" contents)
    string(REGEX REPLACE "-licy_([A-Za-z0-9_]+)" "-licy_\\1d" contents "${contents}")
    file(WRITE "${debug_pkgconfig}" "${contents}")
endif()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

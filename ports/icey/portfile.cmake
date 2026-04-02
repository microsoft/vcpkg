if(DEFINED ENV{ICEY_VCPKG_SOURCE_PATH} AND NOT "$ENV{ICEY_VCPKG_SOURCE_PATH}" STREQUAL "")
    get_filename_component(SOURCE_PATH "$ENV{ICEY_VCPKG_SOURCE_PATH}" ABSOLUTE)
    message(STATUS "Using local icey source tree: ${SOURCE_PATH}")
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO nilstate/icey
        REF "2.4.0"
        SHA512 496f3682ebbdaf4ebdba06d5b81fa7bbcbb4f45b97a270edbc7c0c34eccb00a8bd62cbc7f9c434bb816ac5245eaa0590ad10011a19704ffdb6e6ef75dd006637
        HEAD_REF main
        PATCHES
            fix-libuv-targets.patch
    )
endif()

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
        -DENABLE_NATIVE_ARCH=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/icey)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

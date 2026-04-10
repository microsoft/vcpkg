vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nilstate/icey
    REF 6692243b82e687279ed40f6df54ab93d8964b6a1 # 2.4.2
    SHA512 c1956e7035c2f4aef8cd1005fc8f6373d4b90c4409bd1dd104b5f9f415f9e347da7b1c530ac8f1192f7953a076ec21f0a8aed9618e236324e0c5154f12e79dce
    HEAD_REF main
    PATCHES
        001-devendor-nlohmann-json.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ffmpeg   WITH_FFMPEG
        opencv   WITH_OPENCV
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/json/include/nlohmann")

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

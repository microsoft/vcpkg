vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 df5039e90027a8d9e283a71c114781a3701b828854f866c08a4f9e513c11d387337bc74629d31a270adad12e32d3ee61ff51341c5eff3fbd97392bf8ddafaa9a
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ai        HJ_ENABLE_AI
        algo      HJ_ENABLE_ALGO
        compress  HJ_ENABLE_COMPRESS
        crypto    HJ_ENABLE_CRYPTO
        db        HJ_ENABLE_DB
        encoding  HJ_ENABLE_ENCODING
        hardware  HJ_ENABLE_HARDWARE
        io        HJ_ENABLE_IO
        log       HJ_ENABLE_LOG
        math      HJ_ENABLE_MATH
        misc      HJ_ENABLE_MISC
        net       HJ_ENABLE_NET
        os        HJ_ENABLE_OS
        sync      HJ_ENABLE_SYNC
        testing   HJ_ENABLE_TESTING
        time      HJ_ENABLE_TIME
        types     HJ_ENABLE_TYPES
        util      HJ_ENABLE_UTIL
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_LIB=OFF
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TEST=OFF
        -DBUILD_BENCH=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

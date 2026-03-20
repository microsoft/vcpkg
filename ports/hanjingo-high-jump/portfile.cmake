vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 65081057674916833611dfbb11ba261477f1aebfd7291ed93b1722f8a36e327ad7d82db0b26f6776b73d5ceb862ca167954653adcc4e2374bf0f607eb0724c21
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

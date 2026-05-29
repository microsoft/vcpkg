vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 295a737cf133f9ceaee39577c764b4e337611e7f6cc6ea2499ea8c5052698a9a9ae6268ba4c4b64e0b88eeec4031804cdd933500d66899677e44152097145d9a
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

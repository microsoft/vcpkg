vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 e7bb70810dd23649039c3565d8617e1de343251d0f0db20ee8e1ed2edd25435d1db4cffa41a4b80827ccfbfd1c3e7ef7f365907eb9a893e8ac29189bd6d95f09
    PATCHES
        fix-msvc-core-headers.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        grpc            HJ_ENABLE_GRPC
        lic             HJ_ENABLE_LIC
        singleton       HJ_ENABLE_SINGLETON
        timer           HJ_ENABLE_TIMER
        http            HJ_ENABLE_HTTP
        zmq             HJ_ENABLE_ZMQ
        test            HJ_ENABLE_UNIT_TEST
        bench           HJ_ENABLE_BENCHMARK
        crash           HJ_ENABLE_CRASH
        telemetry       HJ_ENABLE_TELEMETRY
        sync            HJ_ENABLE_SYNC
        options         HJ_ENABLE_OPTIONS
        pdf             HJ_ENABLE_PDF
        fix             HJ_ENABLE_FIX
        math            HJ_ENABLE_MATH
        log             HJ_ENABLE_LOG
        usb-bt          HJ_ENABLE_USB_BT
        gpu             HJ_ENABLE_GPU
        xml             HJ_ENABLE_XML
        protobuf        HJ_ENABLE_PROTOBUF
        yaml            HJ_ENABLE_YAML
        flatbuffer      HJ_ENABLE_FLATBUFFER
        sqlite          HJ_ENABLE_SQLITE
        redis           HJ_ENABLE_REDIS
        ck              HJ_ENABLE_CK
        crypto          HJ_ENABLE_CRYPTO
        gzip            HJ_ENABLE_GZIP
        behavior-tree   HJ_ENABLE_BEHAVIOR_TREE
        qrcode          HJ_ENABLE_QRCODE
        vector-index    HJ_ENABLE_VECTOR_INDEX
        llama           HJ_ENABLE_LLAMA
        asr             HJ_ENABLE_ASR
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_LIB=OFF
        -DBUILD_TEST=OFF
        -DBUILD_BENCH=OFF
        -DHJ_VERSION=${VERSION}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
[[The package hanjingo-high-jump provides CMake targets:

    find_package(hj CONFIG REQUIRED)
    # Note: The 'hj' target provides include paths only.
    # You MUST link the feature libraries via ${hj_LIBRARIES}.
    target_link_libraries(main PRIVATE hj ${hj_LIBRARIES})
]])
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 e39c8acc98a9b3530603fa94781a99b627f52491b982be10ec67be9b9b6ab2dbf5268cf391b3b11a861d3100abcd5d94ea3bc9adc003dce4986b208a887d6bf2
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
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_LIB=OFF
        -DBUILD_TEST=OFF
        -DBUILD_BENCH=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

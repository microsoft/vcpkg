vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 768d17fe0dbd4c1aec90c2b3b61984937f0afaa210749b34be5e4d85e830191e70e40d2aacfa8a1f317ebefeb56ef796f3e1da633c21e49148f60e900cb69b67
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

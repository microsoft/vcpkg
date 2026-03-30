vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl ENABLE_CURL
        openssl ENABLE_OPENSSL
        postgres ENABLE_POSTGRES
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gregorian-09/regime-flow
    REF v1.0.1
    SHA512 fbab0524c5a477cbc42ae035d769211ab524d0af615610da728959c19b503d5655562070e8068b56eaf43ea339e6c4bb715de554e276d86484c6bb5770415651
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DENABLE_IBAPI=OFF
        -DENABLE_ZMQ=OFF
        -DENABLE_REDIS=OFF
        -DENABLE_KAFKA=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RegimeFlow)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

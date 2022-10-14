if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF v1.5.0
    SHA512 a506973223c49531d4b0c3febf5734dfe2e44c22f8854ed96935cda0783a14d0819cc3dbb2d3f8373f960f27acf78aafc777ee76aeb14828df9c4b4434e4fe6f
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        etw WITH_ETW
        zipkin WITH_ZIPKIN
        prometheus WITH_PROMETHEUS
        elasticsearch WITH_ELASTICSEARCH
        jaeger WITH_JAEGER
        otlp WITH_OTLP
        zpages WITH_ZPAGES
)

# opentelemetry-proto is a third party submodule and opentelemetry-cpp release did not pack it.
if(WITH_OTLP)
    set(OTEL_PROTO_VERSION "0.17.0")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/open-telemetry/opentelemetry-proto/archive/v${OTEL_PROTO_VERSION}.tar.gz"
        FILENAME "opentelemetry-proto-${OTEL_PROTO_VERSION}.tar.gz"
        SHA512 b61d7fe7d6e1b5943d45ab9d17c22fe36c0f7a8312f668aea2b6685aa0f5c98aaa41e76659057310ec1f061d36ad9e66993be177039121f62f73858a6749d3d9
    )

    vcpkg_extract_source_archive("${ARCHIVE}" "${SOURCE_PATH}/third_party")
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/opentelemetry-proto")
    file(RENAME "${SOURCE_PATH}/third_party/opentelemetry-proto-${OTEL_PROTO_VERSION}" "${SOURCE_PATH}/third_party/opentelemetry-proto")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_METRICS_PREVIEW=ON
        -DWITH_LOGS_PREVIEW=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/opentelemetry-cpp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

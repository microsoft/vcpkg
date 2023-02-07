if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF v1.8.1
    SHA512 4ad89ef5e154674c591d7ab49d262f23093db8b4d7cf1c69a844e24adab96cff523de0769e5dfe7b2721f5a5e18790b11020021380f587775dd660b09e65a44a
    HEAD_REF main
    PATCHES
        support_absl_cxx17.patch
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
    set(OTEL_PROTO_VERSION "0.19.0")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/open-telemetry/opentelemetry-proto/archive/v${OTEL_PROTO_VERSION}.tar.gz"
        FILENAME "opentelemetry-proto-${OTEL_PROTO_VERSION}.tar.gz"
        SHA512 b6d47aaa90ff934eb24047757d5fdb8a5be62963a49b632460511155f09a725937fb7535cf34f738b81cc799600adbbc3809442aba584d760891c0a1f0ce8c03
    )

    vcpkg_extract_source_archive(src ARCHIVE "${ARCHIVE}")
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/opentelemetry-proto")
    file(COPY "${src}/." DESTINATION "${SOURCE_PATH}/third_party/opentelemetry-proto")
    # Create empty .git directory to prevent opentelemetry from cloning it during build time
    file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/opentelemetry-proto/.git")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_LOGS_PREVIEW=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

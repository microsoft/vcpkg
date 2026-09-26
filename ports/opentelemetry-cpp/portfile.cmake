set(OPENTELEMETRY_PLATFORM_FEATURES)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    list(APPEND OPENTELEMETRY_PLATFORM_FEATURES etw OTELCPP_WITH_ETW)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF "v${VERSION}"
    SHA512 f3e8603d55bca5d5eb96d01cab82470a7c2cca8fb1db48fc0e328af3f4e40928c31f76e5ab61b557bb84d61238b1bceec986d19c7fec9a4a2191d523c49f29a4
    HEAD_REF main
    PATCHES
        fix-span-limits-32-bit.patch
        fix-missing-cstdint.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ${OPENTELEMETRY_PLATFORM_FEATURES}
        zipkin OTELCPP_WITH_ZIPKIN
        prometheus OTELCPP_WITH_PROMETHEUS
        elasticsearch OTELCPP_WITH_ELASTICSEARCH
        otlp-file OTELCPP_WITH_OTLP_FILE
        otlp-http OTELCPP_WITH_OTLP_HTTP
        otlp-grpc OTELCPP_WITH_OTLP_GRPC
        geneva WITH_GENEVA
        user-events WITH_USER_EVENTS
        opentracing OTELCPP_WITH_OPENTRACING
    INVERTED_FEATURES
        user-events BUILD_TRACEPOINTS
)

if(OTELCPP_WITH_OPENTRACING)
    list(APPEND FEATURE_OPTIONS -DCMAKE_REQUIRE_FIND_PACKAGE_OpenTracing=ON)
endif()

# opentelemetry-proto is a third party submodule and opentelemetry-cpp release did not pack it.
if(OTELCPP_WITH_OTLP_FILE OR OTELCPP_WITH_OTLP_GRPC OR OTELCPP_WITH_OTLP_HTTP)
    set(OTEL_PROTO_VERSION "1.8.0")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/open-telemetry/opentelemetry-proto/archive/v${OTEL_PROTO_VERSION}.tar.gz"
        FILENAME "opentelemetry-proto-${OTEL_PROTO_VERSION}.tar.gz"
        SHA512 43e320c365f73e1302951cf69e4f395c8dec9fe3efba802dea10637b61721a64868fb0a45c33d2ac15f99a7ba0b865c268d268a543a4efeff10f5c59407e7ba9
    )

    vcpkg_extract_source_archive(src ARCHIVE "${ARCHIVE}")
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/opentelemetry-proto")
    file(COPY "${src}/." DESTINATION "${SOURCE_PATH}/third_party/opentelemetry-proto")
    # Create empty .git directory to prevent opentelemetry from cloning it during build time
    file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/opentelemetry-proto/.git")
    list(APPEND FEATURE_OPTIONS "-DgRPC_CPP_PLUGIN_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/grpc/grpc_cpp_plugin${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()
list(APPEND FEATURE_OPTIONS -DCMAKE_CXX_STANDARD=14)

set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "OFF")

if(WITH_GENEVA OR WITH_USER_EVENTS)
    # Geneva and user events exporters from opentelemetry-cpp-contrib are tightly coupled with opentelemetry-cpp repo,
    # so they should be ported as a feature under opentelemetry-cpp.
    clone_opentelemetry_cpp_contrib(CONTRIB_SOURCE_PATH)

    if(WITH_GENEVA)
        set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${CONTRIB_SOURCE_PATH}/exporters/geneva")
        if(VCPKG_TARGET_IS_WINDOWS)
            set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}\;${CONTRIB_SOURCE_PATH}/exporters/geneva-trace")
        else()
            set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}\;${CONTRIB_SOURCE_PATH}/exporters/fluentd")
        endif()
    endif()

    if(WITH_USER_EVENTS)
        # The contrib subproject still controls its examples with the legacy cache option.
        list(APPEND FEATURE_OPTIONS -DWITH_EXAMPLES=OFF)
        if(WITH_GENEVA)
            set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}\;${CONTRIB_SOURCE_PATH}/exporters/user_events")
        else()
            set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${CONTRIB_SOURCE_PATH}/exporters/user_events")
        endif()
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DOTELCPP_WITH_EXAMPLES=OFF
        -DOTELCPP_INSTALL=ON
        -DOTELCPP_WITH_BENCHMARK=OFF
        -DOTELCPP_EXTERNAL_COMPONENT_PATH=${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        WITH_GENEVA
        WITH_USER_EVENTS
        BUILD_TRACEPOINTS
        gRPC_CPP_PLUGIN_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig(SKIP_CHECK)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/opentelemetry/sdk/configuration")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(OTELCPP_WITH_ETW)
    list(APPEND LICENSE_FILES "${SOURCE_PATH}/exporters/etw/include/opentelemetry/exporters/etw/LICENSE")
endif()
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        ${LICENSE_FILES}
)

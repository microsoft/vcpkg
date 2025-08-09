if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF "v${VERSION}"
    SHA512 a85869d2858f350e4a3b85e5d68e669a5fff42a2222ba7782bba92f5fe6856a110b3ddc9744a6c3e68c1ddfdc7bdb2b570bbeff78275a4e98cea889a8fda0120
    HEAD_REF main
    PATCHES
        fix-target_link.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        etw WITH_ETW
        zipkin WITH_ZIPKIN
        prometheus WITH_PROMETHEUS
        elasticsearch WITH_ELASTICSEARCH
        otlp-http WITH_OTLP_HTTP
        otlp-grpc WITH_OTLP_GRPC
        geneva WITH_GENEVA
        user-events WITH_USER_EVENTS
        opentracing WITH_OPENTRACING
    INVERTED_FEATURES
        user-events BUILD_TRACEPOINTS
)

# opentelemetry-proto is a third party submodule and opentelemetry-cpp release did not pack it.
if(WITH_OTLP_GRPC OR WITH_OTLP_HTTP)
    set(OTEL_PROTO_VERSION "1.6.0")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/open-telemetry/opentelemetry-proto/archive/v${OTEL_PROTO_VERSION}.tar.gz"
        FILENAME "opentelemetry-proto-${OTEL_PROTO_VERSION}.tar.gz"
        SHA512 0e72e0c32d2d699d7a832a4c57a9dbe60e844d4c4e8d7b39eb45e4282cde89fccfeef893eae70b9d018643782090a7228c3ef60863b00747498e80f0cf1db8ae
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
        -DWITH_EXAMPLES=OFF
        -DOPENTELEMETRY_INSTALL=ON
        -DWITH_BENCHMARK=OFF
        -DOPENTELEMETRY_EXTERNAL_COMPONENT_PATH=${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        WITH_GENEVA
        WITH_USER_EVENTS
        BUILD_TRACEPOINTS
        gRPC_CPP_PLUGIN_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF "v${VERSION}"
    SHA512 97635bbaf6dd567c201451dfaf7815b2052fe50d9bccc97aade86cfa4a92651374d167296a5453031b2681dc302806a289bca011a9e79ddc381a17d6118971d7
    HEAD_REF main
    PATCHES
        # Missing find_dependency for Abseil
        add-missing-find-dependency.patch
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
)

# opentelemetry-proto is a third party submodule and opentelemetry-cpp release did not pack it.
if(WITH_OTLP_GRPC OR WITH_OTLP_HTTP)
    set(OTEL_PROTO_VERSION "1.1.0")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/open-telemetry/opentelemetry-proto/archive/v${OTEL_PROTO_VERSION}.tar.gz"
        FILENAME "opentelemetry-proto-${OTEL_PROTO_VERSION}.tar.gz"
        SHA512 cd20991efb2d7f1bc8650fd0e124be707922b0717e429b6212390cd2c0d0afdb403c9aece196f07ae81ebed948863f4ec75c08ffbb3968795a0010d5cb34dc1b
    )

    vcpkg_extract_source_archive(src ARCHIVE "${ARCHIVE}")
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/opentelemetry-proto")
    file(COPY "${src}/." DESTINATION "${SOURCE_PATH}/third_party/opentelemetry-proto")
    # Create empty .git directory to prevent opentelemetry from cloning it during build time
    file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/opentelemetry-proto/.git")
    list(APPEND FEATURE_OPTIONS -DCMAKE_CXX_STANDARD=14)
    list(APPEND FEATURE_OPTIONS "-DgRPC_CPP_PLUGIN_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/grpc/grpc_cpp_plugin${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "OFF")
if(WITH_GENEVA)
# Geneva exporters from opentelemetry-cpp-contrib are tightly coupled with opentelemetry-cpp repo, so they should be ported as a feature under opentelemetry-cpp.
    vcpkg_from_github(
        OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF d2e6acbf1d20497b9ad27b4e0e428eea11448176
        HEAD_REF main
        SHA512 c22eb720556782e2c08d7b4432cf7252c5bbfb94d8db55d853e2d93eaeb29e039e8db548e9aa75f402701fc640ec7a17ac726c86f8b34364dd45ce88aaa1eab5
    )

    set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${CONTRIB_SOURCE_PATH}/exporters/geneva")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}\;${CONTRIB_SOURCE_PATH}/exporters/geneva-trace")
    else()
        set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}\;${CONTRIB_SOURCE_PATH}/exporters/fluentd")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        -DOPENTELEMETRY_INSTALL=ON
        -DWITH_ABSEIL=ON
        -DOPENTELEMETRY_EXTERNAL_COMPONENT_PATH=${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        WITH_GENEVA
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

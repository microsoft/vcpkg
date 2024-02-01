if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF "v${VERSION}"
    SHA512 38a3796a5f4c28fd54cc2a5475b3a024e2e73594acbc635fccc6358bf4d93ae897fc0ce55a93d27736a08622869ccc9fe9a9ee62e3884adadb3f135c27d378ec
    HEAD_REF main
    PATCHES
        # Missing find_dependency for Abseil
        add-missing-find-dependency.patch
        # Fix problems from removing NOMINMAX on Windows. Fixed in 1.14.0
        fix-nominmax-problems.patch
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
    set(OTEL_PROTO_VERSION "1.0.0")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/open-telemetry/opentelemetry-proto/archive/v${OTEL_PROTO_VERSION}.tar.gz"
        FILENAME "opentelemetry-proto-${OTEL_PROTO_VERSION}.tar.gz"
        SHA512 74de78304a91fe72cfcdbd87fcb19c0d6338c161d6624ce09eac0527b1b43b8a5d8790ae055e1d3d44319eaa070a506f47e740f888c91d724a0aef8b509688f0
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
# TODO: merge the opentelemetry-fluentd port to opentelemery-cpp port.
    vcpkg_from_github(
        OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF bf3e3833498d45865f85423764f0d98372fe5646
        HEAD_REF main
        SHA512 d8468997f8d2545d3bb230fd6c8072d70f6842020e9b6ac9cd7725d4c9e728f307618943c96af9cf9116ea2952c1e225e5dd3d4cf829644ad4f1f4c74dd14a0c
    )
    set(OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "")
    list(APPEND OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS "${CONTRIB_SOURCE_PATH}/exporters/geneva")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        -DOPENTELEMETRY_INSTALL=ON
        -DWITH_ABSEIL=ON
        -DOPENTELEMETRY_EXTERNAL_COMPONENT_PATH="${OPENTELEMETRY_CPP_EXTERNAL_COMPONENTS}"
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

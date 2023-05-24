# Get jaeger-idl from github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jaegertracing/jaeger-idl
    REF b9acaab7b20fd4f984225657ffe272799ebdfefb #commit on 2021-08-04
    SHA512 d136e68e54f39779a48b1c5bc61f81dc06b312120dc8d3788a9c360f89aa924ca4cc074c6515743a930982637f9fca94299000a4b2dca1f9c243d8d9d1c62de2
    HEAD_REF master
)

# Create target directory for proxy/stub generation
file(MAKE_DIRECTORY "${SOURCE_PATH}/data")
# List of input files
set(THRIFT_SOURCE_FILES agent.thrift jaeger.thrift sampling.thrift zipkincore.thrift crossdock/tracetest.thrift baggage.thrift dependency.thrift aggregation_validator.thrift)

# Generate proxy/stubs for the input files
foreach(THRIFT_SOURCE_FILE IN LISTS THRIFT_SOURCE_FILES)
vcpkg_execute_required_process(
    COMMAND "${CURRENT_INSTALLED_DIR}/tools/thrift/thrift" --gen cpp:no_skeleton -o "${SOURCE_PATH}/data" ${THRIFT_SOURCE_FILE}
    WORKING_DIRECTORY "${SOURCE_PATH}/thrift"
    LOGNAME jaeger-idl-${TARGET_TRIPLET}
)
endforeach()

# Save generated proxy/stub target directory
set(IDL_SOURCE_DIR "${SOURCE_PATH}/data/gen-cpp")

# Get jaeger-client-cpp from github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jaegertracing/jaeger-client-cpp
    REF 277fdd75e413c914bff04d510afafc7f0811a31a #v0.7.0
    SHA512 5112bda5ec24621044bbcd5393922564de70f4d696b1d4248e889dd3d49e492155bfc88626fea214ce4e4cb50e9a49ea031ddb8efbaafc6f1753a586db534a50
    HEAD_REF master
    PATCHES
        fix-CMakeLists.patch
)

# Do not use hunter, not testtools and build opentracing plugin
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHUNTER_ENABLED=0
        -DBUILD_TESTING=0
        -DJAEGERTRACING_PLUGIN=0
        -DJAEGERTRACING_BUILD_EXAMPLES=0
)

# Copy generated files over to jaeger-client-cpp
file(GLOB IDL_SOURCE_FILES LIST_DIRECTORIES false "${IDL_SOURCE_DIR}/*")
file(COPY ${IDL_SOURCE_FILES} DESTINATION "${SOURCE_PATH}/src/jaegertracing/thrift-gen")

# Generate Jaeger client
vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

# Cleanup unused Debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/jaegertracing/testutils")

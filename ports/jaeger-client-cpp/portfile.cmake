if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP build is not supported.")
endif()

# Get jaeger-idl from github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jaegertracing/jaeger-idl
    REF 378b83a64a4a822a4e7d2936bac5d787780555ad
    SHA512 eceea3dc806600bea8a05b597e26035e97950db227bbefc582d8f20ad549e0be42ebfad92ef3927ebc4892233bac9bcf85a96a25c17ec71fbca0b1b1755f556f
    HEAD_REF master
)

# Create target directory for proxy/stub generation
file(MAKE_DIRECTORY ${SOURCE_PATH}/data)
# List of input files
set(THRIFT_SOURCE_FILES agent.thrift jaeger.thrift sampling.thrift zipkincore.thrift crossdock/tracetest.thrift baggage.thrift dependency.thrift aggregation_validator.thrift)

# Generate proxy/stubs for the input files
foreach(THRIFT_SOURCE_FILE IN LISTS THRIFT_SOURCE_FILES)
vcpkg_execute_required_process(
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/installed/${TARGET_TRIPLET}/tools/thrift/thrift --gen cpp:no_skeleton -o "${SOURCE_PATH}/data" ${THRIFT_SOURCE_FILE} 
    WORKING_DIRECTORY ${SOURCE_PATH}/thrift
    LOGNAME jaeger-idl-${TARGET_TRIPLET}
)
endforeach()

# Save generated proxy/stub target directory
set(IDL_SOURCE_DIR "${SOURCE_PATH}/data/gen-cpp")

# Get jaeger-client-cpp from github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jaegertracing/jaeger-client-cpp
    REF v0.5.0
    SHA512 d855ecfbb1dadffc8c21ff390717a732e743a1e751759bb85e800a0057d5ec5885080ca5ab9d89761b05d68d71817bb5780f42411a92cb5152a2a0f84b0b035a
    HEAD_REF master
    PATCHES 
       "fix-CMakeLists.patch"
)

# Do not use hunter, not testtools and build opentracing plugin
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DHUNTER_ENABLED=0 -DBUILD_TESTING=0 -DJAEGERTRACING_PLUGIN=0 -DJAEGERTRACING_BUILD_EXAMPLES=0
)

# Copy generated files over to jaeger-client-cpp 
file(GLOB IDL_SOURCE_FILES LIST_DIRECTORIES false ${IDL_SOURCE_DIR}/*)
file(COPY ${IDL_SOURCE_FILES} DESTINATION ${SOURCE_PATH}/src/jaegertracing/thrift-gen)

# Generate Jaeger client
vcpkg_install_cmake()

# Integrate Debug CMake file
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/jaeger-client-cpp/jaegertracingTargets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/jaeger-client-cpp/jaegertracingTargets-debug.cmake)
# Cleanup unused Debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jaeger-client-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jaeger-client-cpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/jaeger-client-cpp/copyright)

# Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/jaegertracing/testutils)

# CURRENT_PACKAGES_DIR = Root of installed Target files
# SOURCE_PATH = Root of unpacked Sources
# CMAKE_CURRENT_SOURCE_DIR = Root of this vcpkg instance

include(vcpkg_common_functions)

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
)

# Do not use hunter, not testtools and build opentracing plugin
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DHUNTER_ENABLED=0 -DBUILD_TESTING=0 -DJAEGERTRACING_PLUGIN=1
)

# Copy generated files over to jaeger-client-cpp 
file(GLOB IDL_SOURCE_FILES LIST_DIRECTORIES false ${IDL_SOURCE_DIR}/*)
file(COPY ${IDL_SOURCE_FILES} DESTINATION ${SOURCE_PATH}/src/jaegertracing/thrift-gen)

# Generate Jaeger client
vcpkg_install_cmake()

# Copy includefiles
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/jaegertracing)
file(GLOB JCCPP_INCLUDE_FILES LIST_DIRECTORIES true ${SOURCE_PATH}/src/jaegertracing/*.h)
file(COPY ${JCCPP_INCLUDE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/jaegertracing)
file(COPY ${CURRENT_PACKAGES_DIR}/src/jaegertracing/Constants.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/jaegertracing)

# Copy binaries
file(COPY ${CURRENT_PACKAGES_DIR}/jaegertracing_plugin.dll DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
# Copy Libraries
file(COPY ${CURRENT_PACKAGES_DIR}/jaegertracing_plugin.dll ${CURRENT_PACKAGES_DIR}/jaegertracing-static.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
# Copy CMake files
#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/jaeger-client-cpp)
#file(GLOB JCCPP_CMAKE_FILES LIST_DIRECTORIES true ${SOURCE_PATH}/src/jaegertracing/*.h)
#file(COPY ${CURRENT_PACKAGES_DIR}/jaegertracing_plugin.dll ${CURRENT_PACKAGES_DIR}/jaegertracing-static.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jaeger-client-cpp/copyright)

# Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/jaegertracing/testutils)
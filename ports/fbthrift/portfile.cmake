vcpkg_fail_port_install(ON_ARCH "x86" "arm")

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/fbthrift
    REF v2021.10.11.00
    SHA512 2836646f1c6ca64068813c2a6449eb81238b2ade4eb4c0eb62433140279279fa7ea5d61e33c8f102d86b364a39db74ed9a296b516f4ad325a253c5d3a6e3491e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBISON_EXECUTABLE=${BISON}
        -DFLEX_EXECUTABLE=${FLEX}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/fbthrift)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# There should be no empty directories in vcpkg/packages/fbthrift_x64-linux
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/transport/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/util/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/server/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/common/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/core/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/inmemory/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/protocol/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/security/extensions/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/security/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/frozen/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/reflection/docs
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/util/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/test
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/benchmark
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/thrift/annotation
)

vcpkg_copy_tools(TOOL_NAMES thrift1 AUTO_CLEAN)
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

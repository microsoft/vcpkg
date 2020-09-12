vcpkg_fail_port_install(ON_ARCH "x86" "arm")

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/fbthrift
    REF 3b56786f0822f78a408addffaf3a54b1b8c86dcd # v2019.11.11.00
    SHA512 d892c6825345d2dc68abbe7a0eacb5ee0444fdea328d8d6bbcd512752058a2de715c03567120090a355115bb9d5d41f3f9c8dc2f82b8054d0b5a2fd1621bf473
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBISON_EXECUTABLE=${BISON}
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
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/test
)

vcpkg_copy_tools(TOOL_NAMES thrift1 AUTO_CLEAN)
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

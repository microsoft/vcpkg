vcpkg_fail_port_install(ON_ARCH "x86" "arm")

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/fbthrift
    REF e184b41448dab2f462094fa005ed05269cfba3e3 # v2020.10.19.00
    SHA512 df03e1779fd3f1868ed7be21292bcd91ae65bcca591b0265a40391dde7e3b3b81d83fe7eb4ec8dd5c440be471375b8e2c8c24befefaca3ae0cab9ce10bfd362c
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

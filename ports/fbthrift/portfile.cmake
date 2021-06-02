vcpkg_fail_port_install(ON_ARCH "x86" "arm")

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/fbthrift
    REF v2021.05.31.00
    SHA512 4aa55220b014d2ba2d7f7daf81dffa1276e8f43e5a25c2767819580fad42a39df04656f41e0ebe0302651833e3e994cabb9ded98ea32627ffd90fb91c9c1cc58
    HEAD_REF master
    PATCHES
        fix-sodium-target.patch
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
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/benchmark
    ${CURRENT_PACKAGES_DIR}/include/thrift/lib/thrift/annotation
)

vcpkg_copy_tools(TOOL_NAMES thrift1 AUTO_CLEAN)
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

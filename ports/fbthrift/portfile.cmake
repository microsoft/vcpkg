vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/fbthrift
    REF "v${VERSION}"
    SHA512 a288bd91f3f0b7adb0d5dcfc6e7fef2f60a18ea56545e63e67d449a72986e710c2f58c8782d0950ef48f7a6bf331af0bc2019240638ece4cdacebec4571c920e
    HEAD_REF main
    PATCHES
        fix-deps.patch
        fix-test.patch
)

file(REMOVE "${SOURCE_PATH}/thrift/cmake/FindGMock.cmake")
file(REMOVE "${SOURCE_PATH}/thrift/cmake/FindOpenSSL.cmake")
file(REMOVE "${SOURCE_PATH}/thrift/cmake/FindZstd.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGMock.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindLibEvent.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindSodium.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindZstd.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-Dthriftpy=OFF"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fbthrift)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# There should be no empty directories in vcpkg/packages/fbthrift_x64-linux
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/transport/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/util/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/async/metadata/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/debug_thrift_data_difference/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/detail/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/folly_dynamic/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/frozen/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/patch/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/protocol/detail/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/protocol/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/protocol/tool"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/reflection/demo"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/reflection/docs"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/runtime/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/schema/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/security/extensions/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/security/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/server/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/core/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/common/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/server/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/inmemory/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/rocket/client/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/rocket/compression/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/rocket/framing/parser/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/rocket/payload/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/rocket/server/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/util/gtest/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/util/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/visitation/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/benchmark"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/thrift/annotation"
)

vcpkg_copy_tools(TOOL_NAMES thrift1 AUTO_CLEAN)
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/share/fbthrift/FBThriftConfig.cmake")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fbthrift/FBThriftConfig.cmake" 
        "${PACKAGE_PREFIX_DIR}/lib/cmake/fbthrift" "${PACKAGE_PREFIX_DIR}/share/fbthrift")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fbthrift/FBThriftConfig.cmake" 
        "${PACKAGE_PREFIX_DIR}/bin/thrift1.exe" "${PACKAGE_PREFIX_DIR}/tools/fbthrift/thrift1.exe")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fbthrift/FBThriftConfig.cmake" 
        "${PACKAGE_PREFIX_DIR}/bin/thrift1" "${PACKAGE_PREFIX_DIR}/tools/fbthrift/thrift1")
endif()

# Only used internally and removed in master
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fbthrift/FBThriftTargets.cmake" "LOCATION_HH=\\\"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/thrift/compiler/location.hh\\\"" "" IGNORE_UNCHANGED)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

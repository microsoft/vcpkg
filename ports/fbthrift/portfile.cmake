vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/fbthrift
    REF v2022.01.31.00
    SHA512 159457398fdc0c89c34364b8a89068127c3519ce35af349776016e0ae37ae9508689853e0e371c2065fd715451f466e37c7e3799e054eca02cbc4717809150ab
    HEAD_REF master
    PATCHES
        add-missing-algorithm-include.patch # https://github.com/facebook/fbthrift/commit/f2151fa730058a1baf23ed3dc082c91df6351da1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fbthrift)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# There should be no empty directories in vcpkg/packages/fbthrift_x64-linux
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/transport/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp/util/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/server/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/common/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/http2/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/core/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/transport/inmemory/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/protocol/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/security/extensions/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/security/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/frozen/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/reflection/docs"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/util/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/cpp2/visitation/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/test"
    "${CURRENT_PACKAGES_DIR}/include/thrift/lib/py3/benchmark"
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

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

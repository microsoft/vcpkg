include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/jsonnet
    REF 8606e21dfb599f838890944c6d96d9aa7c70b8c1
    SHA512 955a801a0e50c71a8e7f79cb432496ff23c0769ea5bb17c8dbda8f88d0936d8c3c1213c219641982d606c91adcc48c4354ff02b759f21202831a23ca584d3f0b
    HEAD_REF master
)

vcpkg_execute_required_process(
  COMMAND Powershell -Command "((Get-Content -Encoding Byte ${SOURCE_PATH}/stdlib/std.jsonnet) -join ',') + ',0' > ${SOURCE_PATH}/core/std.jsonnet.h"
  WORKING_DIRECTORY ${SOURCE_PATH}
  LOGNAME "std.jsonnet"
)


file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/jsonnet)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsonnet RENAME copyright)

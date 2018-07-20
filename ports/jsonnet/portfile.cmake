include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/jsonnet
    REF c93f74374ea9ce904669bb4633fcbbfe558959d2
    SHA512 7fec45ef1a566d5b0f8384a315cc19ae3e9a3def9717b8c94cdbed107dc3fe4cba9b003ddda4ed4916b32061a01ea5be6fcfbbccef90fbcaf4387a03d31fb679
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

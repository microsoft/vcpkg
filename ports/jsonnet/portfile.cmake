include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/jsonnet
    REF 48df4a1007a88202495a30bf2fa65528335b35e6
    SHA512 46734d797499d51a79c1c63d653bc8e6496d385a57c7a83a45c3ab82fa4f106abdb67a57b9641d5c9e1cf286f4f0a66cfdbc5e1987bda234d614c91d7be79c94
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

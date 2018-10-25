include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/jsonnet
    REF 8b15e8d5c1202dde1be2cd8631025ff7719b688b
    SHA512 5eb00c7473503ae4bab3aca1fe822bf3df8ae186db4bd46feb26114395690119e1934cbe601f033075d9e2672c80b1441741607e63b0d6b1fab559be6cde84d8
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

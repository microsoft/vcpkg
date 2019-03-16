include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/jsonnet
    REF a0876b301daf8f45e16ac5f7bb814d0617772bb0
    SHA512 a57380ecc578b11f3a763202abb7ab703f2cc3c098ca7602d0bd199594a9e8d1cebc6d51332658edb08bf088e565d6afae0cb2faaf127fa33542a406de1ac055
    HEAD_REF master
)

if (WIN32)
  vcpkg_execute_required_process(
    COMMAND Powershell -Command "((Get-Content -Encoding Byte ${SOURCE_PATH}/stdlib/std.jsonnet) -join ',') + ',0' > ${SOURCE_PATH}/core/std.jsonnet.h"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME "std.jsonnet"
  )
else()
  vcpkg_execute_required_process(
    COMMAND bash -c "((od -v -Anone -t u1 ${SOURCE_PATH}/stdlib/std.jsonnet | tr ' ' '\\n' | grep -v '^$' | tr '\\n' ',' ) && echo '0') > ${SOURCE_PATH}/core/std.jsonnet.h"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME "std.jsonnet"
  )
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/jsonnet)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsonnet RENAME copyright)

include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/jsonnet
  REF d192671391113657ccc4f22511ec1b2bd2ea5f1a
  SHA512 c2ee03b89ee5fe62539afc9e5dee51df389dde8c519c7b7f3e139267b9e22d72761120ba9557eb72f3b4f454771fca241ef9a137963c6944b9f84712ef9cb7d8
  HEAD_REF master
  PATCHES
	001-enable-msvc.patch
)

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  vcpkg_execute_required_process(
    COMMAND Powershell -Command "((Get-Content -Encoding Byte \"${SOURCE_PATH}/stdlib/std.jsonnet\") -join ',') + ',0' > \"${SOURCE_PATH}/core/std.jsonnet.h\""
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "std.jsonnet"
  )
else()
  vcpkg_execute_required_process(
    COMMAND bash -c "((od -v -Anone -t u1 \"${SOURCE_PATH}/stdlib/std.jsonnet\" | tr ' ' '\\n' | grep -v '^$' | tr '\\n' ',' ) && echo '0') > \"${SOURCE_PATH}/core/std.jsonnet.h\""
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "std.jsonnet"
  )
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DBUILD_JSONNET=OFF -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/jsonnet)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsonnet RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

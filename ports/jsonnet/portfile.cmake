include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/jsonnet
  REF v0.13.0
  SHA512 d19e5398763e37b79b0ef02368f6bd6215d2df234b5ff7a6d98e2306a0d47290600061c9f868c0c262570b4f0ee9eee6c309bcc93937b12f6c14f8d12339a7d5
  HEAD_REF master
  PATCHES
	001-enable-msvc.patch
)

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  # Get PowerShell version
  set(PS_VER "")
  execute_process(
      COMMAND Powershell -Command "Get-Host"
      OUTPUT_VARIABLE PS_VER
      ERROR_QUIET
      RESULT_VARIABLE error_code
      WORKING_DIRECTORY "${SOURCE_PATH}")
  
  string(REGEX MATCH "Version\ *:\ *([0-9\.]+)" PS_VER ${PS_VER})
  message(STATUS "Current PowerShell ${PS_VER}")
  # PowerShell v6.0 change the parameter -Encoding Byte to -AsByteStream
  if (PS_VER VERSION_LESS "6")
    set(PS_COMMAND "((Get-Content -Encoding Byte \"${SOURCE_PATH}/stdlib/std.jsonnet\") -join ',') + ',0' > \"${SOURCE_PATH}/core/std.jsonnet.h\"")
  else()
    set(PS_COMMAND "((Get-Content -AsByteStream \"${SOURCE_PATH}/stdlib/std.jsonnet\") -join ',') + ',0' > \"${SOURCE_PATH}/core/std.jsonnet.h\"")
  endif()
  vcpkg_execute_required_process(
    COMMAND Powershell -Command ${PS_COMMAND}
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

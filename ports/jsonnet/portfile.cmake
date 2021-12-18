if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/jsonnet
  REF v0.17.0
  SHA512 D3EE6947163D8ABCED504FF37ECF365C0311164CBF243D4C635D34944F0831CA9FCE2470ACF00EB9A218F82A2E553B3F885DB9BD21BB9DCEFBD707FA0202925D
  HEAD_REF master
  PATCHES
    001-enable-msvc.patch
    002-fix-dependency-and-install.patch
    0003-use-upstream-nlohmann-json.patch
    0004-incorporate-md5.patch
)

# see https://github.com/google/jsonnet/blob/v0.17.0/Makefile#L214
if(VCPKG_TARGET_IS_WINDOWS)
  find_program(PWSH_PATH pwsh)
  vcpkg_execute_required_process(
    COMMAND "${PWSH_PATH}" -Command "((Get-Content -AsByteStream \"${SOURCE_PATH}/stdlib/std.jsonnet\") -join ',') + ',0' | Out-File -Encoding Ascii \"${SOURCE_PATH}/core/std.jsonnet.h\""
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_SHARED ON)
    set(BUILD_STATIC OFF)
else()
    set(BUILD_SHARED OFF)
    set(BUILD_STATIC ON)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_SHARED_BINARIES=${BUILD_SHARED}
    -DBUILD_STATIC_LIBS=${BUILD_STATIC}
    -DBUILD_JSONNET=OFF
    -DBUILD_JSONNETFMT=OFF
    -DBUILD_TESTS=OFF
    -DUSE_SYSTEM_JSON=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/jsonnet")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

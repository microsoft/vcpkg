if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/jsonnet
  REF 3f58aa551c917d6a7a2c6d042ee27f93d895ac0b # v0.16.0
  SHA512 448f4ff433a43ec21c3b67ea508d624e03dac420878e453e908a465cd517c79ae657f107c92e28a4ae2d2527baaf9a3ae1c6ea4c7e7e4f5062d3fad4e76e668c
  HEAD_REF master
  PATCHES
    001-enable-msvc.patch
    002-fix-dependency-and-install.patch
    0003-use-upstream-nlohmann-json.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_execute_required_process(
    COMMAND Powershell -Command "((Get-Content -AsByteStream \"${SOURCE_PATH}/stdlib/std.jsonnet\") -join ',') + ',0' | Out-File -Encoding Ascii \"${SOURCE_PATH}/core/std.jsonnet.h\""
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

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBUILD_SHARED_BINARIES=${BUILD_SHARED}
    -DBUILD_STATIC_LIBS=${BUILD_STATIC}
    -DBUILD_JSONNET=OFF
    -DBUILD_JSONNETFMT=OFF
    -DBUILD_TESTS=OFF
    -DUSE_SYSTEM_JSON=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/jsonnet)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

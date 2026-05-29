if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/jsonnet
  REF "v${VERSION}"
  SHA512 4fc39bd5e138623ba1ac7cf88594ea7957e9c3bcb952f0e9e346059a9de08eac3f60788376c31a70b34d6d522737a67ad4a122fadcd9621868722c23d9361d05
  HEAD_REF master
  PATCHES
    001-enable-msvc.patch
    002-fix-dependency-and-install.patch
    0004-incorporate-md5.patch
    0005-use-upstream-rapidyaml.patch
    0006-use-cxx17.patch
)

# see https://github.com/google/jsonnet/blob/v0.18.0/Makefile#L220
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

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_SHARED_BINARIES=${BUILD_SHARED}
    -DBUILD_STATIC_LIBS=${BUILD_STATIC}
    -DBUILD_JSONNET=OFF
    -DBUILD_JSONNETFMT=OFF
    -DBUILD_TESTS=OFF
    -DUSE_SYSTEM_JSON=ON
    -DUSE_SYSTEM_RYML=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/jsonnet")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

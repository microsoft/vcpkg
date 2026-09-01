vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/rego-cpp
    REF "v${VERSION}"
    SHA512 41c9a9ef4f531b872c5fc5a4ba4a1ac1a393a907e48e9dc22abf069098ce71045c294503a24f28c177058bbe3e148e6be0f49a73fbc46c64547c249f70f6fcd7
    HEAD_REF main
    PATCHES
      add-bigobj.diff # src\rego_to_bundle.cc : fatal error C1128: number of sections exceeded object file format limit: compile with /bigobj
)

# NOTE: The CI overlay port (see .github/workflows/pr_gate.yml,
# vcpkg-integration) uses sed to extract from the "if" line below onwards to
# build a portfile that points at the local checkout. If you reorder code above
# this line, update the sed pattern there.
if("openssl3" IN_LIST FEATURES)
  set(CRYPTO_BACKEND "openssl3")
else()
  set(CRYPTO_BACKEND "")
endif()

if("tools" IN_LIST FEATURES)
  set(BUILD_TOOLS ON)
else()
  set(BUILD_TOOLS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREGOCPP_USE_FETCH_CONTENT=OFF
        -DREGOCPP_BUILD_TOOLS=${BUILD_TOOLS}
        -DREGOCPP_BUILD_TESTS=OFF
        -DREGOCPP_BUILD_DOCS=OFF
        -DREGOCPP_CRYPTO_BACKEND=${CRYPTO_BACKEND}
)

vcpkg_cmake_install()

if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES rego AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME regocpp CONFIG_PATH share/regocpp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/src/builtins/base64/base64.cpp"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

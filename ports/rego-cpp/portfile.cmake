vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/rego-cpp
    REF "v${VERSION}"
    SHA512 a9e7b6202fdc7b7168433227c7bc67492d52bdf10c5d9b2c0954aa66a9eb5a16a9b4de7eb7385a335c6685111393aad6840c171ab12b3e6b2fd493b5bffea21c
    HEAD_REF main
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
        -DREGOCPP_USE_SNMALLOC=OFF
        -DREGOCPP_CRYPTO_BACKEND=${CRYPTO_BACKEND}
)

vcpkg_cmake_install()

if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES rego AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME regocpp CONFIG_PATH share/regocpp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

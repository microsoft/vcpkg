vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Trieste
    REF "v${VERSION}"
    SHA512 5499e461e92c2d86853e9666c003e755c6d77f2dde0bd44f12a09a4fc7a2446e871d34fcc769b18f5ee87f8ceea79476284620d50c61ef1593e7126d273f79fc
    HEAD_REF main
)

# NOTE: The CI overlay port (see .github/workflows/buildtest.yml,
# vcpkg-integration) uses sed to extract from the "if" line below onwards to
# build a portfile that points at the local checkout. If you reorder code above
# this line, update the sed pattern there.
if("parsers" IN_LIST FEATURES)
  set(BUILD_PARSERS ON)
else()
  set(BUILD_PARSERS OFF)
  # Without parsers, this is a header-only library.
  set(VCPKG_BUILD_TYPE release)
endif()

if("snmalloc" IN_LIST FEATURES)
  set(USE_SNMALLOC ON)
else()
  set(USE_SNMALLOC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DTRIESTE_USE_FETCH_CONTENT=OFF
        -DTRIESTE_BUILD_SAMPLES=OFF
        -DTRIESTE_BUILD_PARSERS=${BUILD_PARSERS}
        -DTRIESTE_ENABLE_TESTING=OFF
        -DTRIESTE_USE_SNMALLOC=${USE_SNMALLOC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/trieste/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(NOT "parsers" IN_LIST FEATURES)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

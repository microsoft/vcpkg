vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Trieste
    REF "v${VERSION}"
    SHA512 cd92ef15181c7adc4e777342b9e5ae60ec1b12356d3742044d98e54d3f9a44012c377eafbc02f92afc7f80e963b32a22e5230f765a2f63345139050512bc3af0
    HEAD_REF main
    PATCHES
      artifact-names.diff
)

# NOTE: The CI overlay port (see .github/workflows/buildtest.yml,
# vcpkg-integration) uses sed to extract from the "if" line below onwards to
# build a portfile that points at the local checkout. If you reorder code above
# this line, update the sed pattern there.
if("parsers" IN_LIST FEATURES)
  set(BUILD_PARSERS ON)
  # The parser libraries lack __declspec(dllexport) annotations,
  # so they must be built as static libraries on Windows.
  if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
  endif()
else()
  set(BUILD_PARSERS OFF)
  # Without parsers, this is a header-only library.
  set(VCPKG_BUILD_TYPE release)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DTRIESTE_USE_FETCH_CONTENT=OFF
        -DTRIESTE_BUILD_SAMPLES=OFF
        -DTRIESTE_BUILD_PARSERS=${BUILD_PARSERS}
        -DTRIESTE_ENABLE_TESTING=OFF
        -DTRIESTE_USE_SNMALLOC=OFF
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

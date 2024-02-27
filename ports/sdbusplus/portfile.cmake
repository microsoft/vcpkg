if(VCPKG_TARGET_IS_LINUX)
  message("Warning: `sdbusplus` requires GCC 13+")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openbmc/sdbusplus
    REF e12a23cc2e28b49234d042ac60eafec4ce4e3a3b
    SHA512 5f9c90887caa55b57a3eebe1862eace157979a9035ec924383c3c05d2659a67eb1c5621708598fae7b0d968a1a227ddaf6adc4b903d6868276c8f3ce24798d6a 
    PATCHES
      # disabling boost definitions that cannot be defined because if privately linked to this library in one place
      # and use different definitions for boost asio in other places will produce sigsev fault
      disable-boost-definitions.patch
      async-option.patch
)

# Hack to work with old meson version
file(COPY_FILE "${SOURCE_PATH}/meson.options" "${SOURCE_PATH}/meson_options.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

x_vcpkg_get_python_packages(
    PYTHON_VERSION "3"
    PACKAGES mako pyyaml inflection
)

if ("asio-only" IN_LIST FEATURES)
  set(USE_ASYNC disabled)
else()
  set(USE_ASYNC enabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -Dtests=disabled
      -Dexamples=disabled
      -Dasync=${USE_ASYNC}
      -Dcpp_std=c++20 # todo revert to c++23 when meson tool has been upgraded
)

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

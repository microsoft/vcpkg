vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openbmc/sdbusplus
    REF f6e67e87893b531d527d60a24d192bb6327964ef
    SHA512 12b23243affcf43460b916f05293eedf3cb3992177dc47a19424c3686058b8a11495509960b3fbb6c44fbbdd5686153d51eb6030c6cc816748a3811f0dbb0784
    PATCHES
      # disabling boost definitions that cannot be defined because if privately linked to this library in one place
      # and use different definitions for boost asio in other places will produce sigsev fault
      disable-boost-definitions.patch
      async-option.patch
)

# Hack to work with old meson version
file(COPY "${CMAKE_CURRENT_LIST_DIR}/meson_options.txt" DESTINATION "${SOURCE_PATH}")

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

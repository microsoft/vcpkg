# The library is not header-only and installs a CMake package config, so the
# standard cmake helpers do the whole job.
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO libtmux/libtmux-cxx
  REF "v${VERSION}"
  SHA512 23cfb3723834b3982bfc2bba6ca9a7998f1817bf60700e13db154638e45d4e68346a8f5f65f1293187fe39326aed1e76f5113b6d0fbd0090a984d6d0e8a65439
  HEAD_REF master)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    # This project's own tests need GoogleTest and a real tmux, and its
    # examples need a tmux to run against. Neither belongs in a consumer's
    # dependency graph.
    -DLIBTMUX_BUILD_TESTS=OFF
    -DLIBTMUX_BUILD_EXAMPLES=OFF
    # `libtmux::testing` does belong there, and follows those two switches
    # unless it is asked for. It is the fixture a consumer's own suite runs
    # on — a private tmux server per test — and it names no test framework and
    # links nothing beyond the library, so shipping it costs a consumer an
    # archive they never link unless they ask for the component.
    -DLIBTMUX_BUILD_TESTING_LIBRARY=ON)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME libtmux CONFIG_PATH lib/cmake/libtmux)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

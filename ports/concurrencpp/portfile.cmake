vcpkg_fail_port_install(ON_LIBRARY_LINKAGE "dynamic")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO David-Haim/concurrencpp
  REF v.0.1.2
  SHA512 48e3acca73c7b06940d41e84334cec56e7657c45f862d53e8e4ca1fb76b792c5b136ce4eeaf8afb8db95e746442fb45031c2c695ce60fcbe92ce91e5e1e80b25
  HEAD_REF master
  PATCHES
    fix-include-path.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/concurrencpp-0.1.2 TARGET_PATH share/concurrencpp)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/concurrencpp RENAME copyright)

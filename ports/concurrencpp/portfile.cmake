if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO David-Haim/concurrencpp
  REF v.0.1.2
  SHA512 48e3acca73c7b06940d41e84334cec56e7657c45f862d53e8e4ca1fb76b792c5b136ce4eeaf8afb8db95e746442fb45031c2c695ce60fcbe92ce91e5e1e80b25
  HEAD_REF master
  PATCHES
    make-linkage-configurable.patch
    fix-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/concurrencpp-0.1.2 )

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/concurrencpp RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orocos/orocos_kinematics_dynamics
    REF v1.4.0
    SHA512 7156465e2aff02f472933617512069355836a03a02d4587cfe03c1b1d667a9762a4e3ed6e055b2a44f1fce1b6746179203c7204389626a7b458dcab1b28930d8
    HEAD_REF master
    PATCHES export-include-dir.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/orocos_kdl"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/orocos_kdl/cmake PACKAGE_NAME orocos_kdl)

file(READ "${CURRENT_PACKAGES_DIR}/share/orocos_kdl/orocos_kdl-config.cmake" _contents)
string(REPLACE "\${CMAKE_CURRENT_LIST_DIR}/../../.." "\${CMAKE_CURRENT_LIST_DIR}/../.." _contents "${_contents}")
string(REPLACE "\${_IMPORT_PREFIX}" "\${CMAKE_CURRENT_LIST_DIR}/../.." _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/orocos_kdl/orocos_kdl-config.cmake" "${_contents}")

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/share/doc"
  "${CURRENT_PACKAGES_DIR}/doc/liborocos-kdl")

file(INSTALL "${SOURCE_PATH}/orocos_kdl/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_fixup_pkgconfig()

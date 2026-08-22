vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orocos/orocos_kinematics_dynamics
    REF "${VERSION}"
    SHA512 5d2b3329c1015c1ed2f91860cc95f933f3fd42405e42dfe06f6c117c0c64bde8f8b1f49b2399555ee70782dfbf1da4d4a7a92a1860aee10e5bceff95a892b4a2
    HEAD_REF master
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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orocos/orocos_kinematics_dynamics
    REF "v${VERSION}"
    SHA512 9774b76b755ea81168390643813789783f60d0b1cdb46cd250e3e0d27f75a6cf2fd3bfd2081c04e30a14ff4fc70d0080c9b43b82ee181c2dda82f23f052b338d
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

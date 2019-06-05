include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO stephane/libmodbus
  REF v3.1.4
  SHA512 dc13b680a13ae2c952fe23cfe257a92a2be4823005b71b87e9520a3676df220b749d04c0825b1d1da02ac8b6995315e5cda2c8fd68e4672dd60e0b3fe739728b
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LESSER DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmodbus RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

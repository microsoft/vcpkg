if(VCPKG_CMAKE_SYSTEM_NAME  STREQUAL WindowsStore)
  message(FATAL_ERROR "Windowstore not supported")
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO OpenMPT/openmpt
  REF  cf2390140c37a53ecf7d5fe73412982d346efba4
  SHA512  6401bac7a899eaacebb601591f982fabde6351f1c0dc0c2d24f1f303b78592e7883a84463bdf3cf0fd029eb38d7b7085fdfadafea2931b307b43d0b601db863e
  HEAD_REF master
  PATCHES
    deaf2e3837fb08b1a53fd21bb53adbafe0a84e7d.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/libopenmpt)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libopenmpt RENAME copyright)

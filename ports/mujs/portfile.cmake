include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message(WARNING "building static")
  set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ccxvii/mujs
  REF 25821e6d74fab5fcc200fe5e818362e03e114428
  SHA512 8f4ae9151ce6b7ef4b1951d23f95167d16a2acb0eba4ee656ad56c92cd19af3e049c6903533d93caf0206f776374f3203b6a3f3e1748c4e720dc11ed8ac26342
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mujs RENAME copyright)

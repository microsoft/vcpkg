include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO enki/libev
    REF 93823e6ca699df195a6c7b8bfa6006ec40ee0003
    SHA512  7a1bf7c7cc6d583207d8cbfe683a4c92ba38ce9976a977eff3de527e5897cbd68407f4f57af560028d0545ffc960e5f82ba95020b1a3e015ef7cbb89178be09f
    HEAD_REF master
)

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
  ${CMAKE_CURRENT_LIST_DIR}/fix-ev-c.patch
  ${CMAKE_CURRENT_LIST_DIR}/fix-event-h.patch
  ${CMAKE_CURRENT_LIST_DIR}/fix-symbols-ev.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/configure.cmake DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake DESTINATION ${SOURCE_PATH})




vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libev RENAME copyright)

vcpkg_copy_pdbs()

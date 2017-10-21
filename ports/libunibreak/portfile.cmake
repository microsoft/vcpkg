include(vcpkg_common_functions)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message(WARNING "Dynamic not supported building static")
  set(VCPKG_LIBRARY_LINKAGE static)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adah1972/libunibreak
  REF  libunibreak_4_0
  SHA512  f11295133a1c65f365a5287f7377f69ac7998f19b06d44818fb55c8a5ba3edabc36de8d1b7c0d38db9d982f0e443d0a751f6d51841865094122df4cd74c9af3b
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libunibreak RENAME copyright)

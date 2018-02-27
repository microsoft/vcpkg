include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message(WARNING "Dynamic not supported building static")
  set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/piex
  REF 938f8b6e49ae43b062f76aad968ff76f5f33c965
  SHA512 abe145f29d210b03eb4340a506cd3e061a9ffe69217f916310308c6c8095ebe3229fb969a4403d1ca06375c8c87e78db8bceee89f7963116f80acdce463c556b
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/piex RENAME copyright)

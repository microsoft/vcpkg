include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO asmjit/asmjit
  REF 771d66b301e60ebc3ffa69b11765622c547df6ab
  SHA512 02ae822a33d50810fc0833b647bd6c29851b147ae4e388fd29d54567e6ed928173b961d3f3f323b243719092c2947bd6f374bc5d6051817e8153688868473830
  HEAD_REF master
)


if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DASMJIT_STATIC=1
  )
else()
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
  )
endif()



vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()



# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/asmjit RENAME copyright)

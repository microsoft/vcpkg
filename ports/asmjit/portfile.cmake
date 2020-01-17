include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO asmjit/asmjit
  REF 7e164e3edeefb76d8a2da4fbe84957ece0d07a13
  SHA512 19d0a7f7a7cb4e6bd6c03f2e29ab012edf67ba4ba92789fd81e71a4937f1271a5124fa9c02d40d202bad7785b9e5ae21a3a72048cdeb8781c1b927c9717669c8
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

vcpkg_fail_port_install(ON_ARCH "arm")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO asmjit/asmjit
  REF 8474400e82c3ea65bd828761539e5d9b25f6bd83
  SHA512 435be4ed22abbbbcdea3869b31bc2fc27aae969775773c24155d7490bca9591f51613fa3319cce54200c6d18dbe73a6be2d5449c49afb46934d93760501e98f6
  HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(ASMJIT_STATIC 1)
else()
    set(ASMJIT_STATIC 0)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DASMJIT_STATIC=${ASMJIT_STATIC}
 )


vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

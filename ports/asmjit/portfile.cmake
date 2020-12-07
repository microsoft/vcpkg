vcpkg_fail_port_install(ON_ARCH "arm")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO asmjit/asmjit
  REF 5bc166efdb419f88bd5b5774c62cfc4d08a0bfa4 # accessed on 2020-09-14
  SHA512 6e31617e62dccbec5fa4d8aeacb1076167f870578a0dd2915403d414f8fcaab16692968287f912dc41a2ec7d10a343d5b687144f04d2ec7adb2880044752543c
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/asmjit)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

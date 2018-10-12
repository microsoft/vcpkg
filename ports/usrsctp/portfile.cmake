include(vcpkg_common_functions)
vcpkg_check_linkage(
  ONLY_STATIC_LIBRARY
)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sctplab/usrsctp
    REF 35c1d97020a20014b989bba4f20225fd9429c4f4
    SHA512 18786825ec2c8c8aeb6b0bcab97deeac40420f7a9bdb427c891b26633ff759266409381ae2545c5572a740322ae1a56f80da1a784d71e50fce97177c343d27ce
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)


vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB_RECURSE release_dlls ${CURRENT_PACKAGES_DIR}/lib/*.dll)
file(GLOB_RECURSE debug_dlls ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)

if(release_dlls)
  file(REMOVE ${release_dlls})
endif()
if(debug_dlls)
  file(REMOVE ${debug_dlls})
endif()


file(INSTALL  ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/usrsctp RENAME copyright)

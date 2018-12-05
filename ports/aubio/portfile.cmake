include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aubio-3c230fae309e9ea3298783368dd71bae6172359a)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aubio/aubio
    REF 967e4041f21d7eec9db319db98a37489aa19460c 
    SHA512 76ab82bc509350fb3fe0cee5806c6f8af72a6ce97b4aba887d8f66f13f924eebea12fbdfeab9c1f201c6141d703336ebbf13813f54c8d0fa20507e048d15b2cd 
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_RELEASE
    -DTOOLS_INSTALLDIR=tools/aubio
    -DBUILD_TOOLS=ON
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=1
    -DBUILD_TOOLS=OFF
)
vcpkg_install_cmake()

# Handle copyright and credentials
file(COPY
    ${SOURCE_PATH}/COPYING
    ${SOURCE_PATH}/AUTHORS
    ${SOURCE_PATH}/ChangeLog
    ${SOURCE_PATH}/README.md
  DESTINATION
    ${CURRENT_PACKAGES_DIR}/share/aubio)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/aubio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/aubio/COPYING ${CURRENT_PACKAGES_DIR}/share/aubio/copyright)

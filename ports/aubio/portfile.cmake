include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aubio-3c230fae309e9ea3298783368dd71bae6172359a)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aubio/aubio
    REF 0.4.8 
    SHA512 0422ec9ceb645dd5cdb1ca8b17f552edf9197dbf9c929ca75aacfb89f092c02db8b6d2b8aec567ddc1df5b310770de77cd941b45ed74700c3d3584924f39b576
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

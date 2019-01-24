include(vcpkg_common_functions)

set(OPENEXR_VERSION 2.3.0)
set(OPENEXR_HASH 268ae64b40d21d662f405fba97c307dad1456b7d996a447aadafd41b640ca736d4851d9544b4741a94e7b7c335fe6e9d3b16180e710671abfc0c8b2740b147b2)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openexr/openexr
  REF v${OPENEXR_VERSION}
  SHA512 ${OPENEXR_HASH}
  HEAD_REF master
)

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DOPENEXR_BUILD_PYTHON_LIBS:BOOL=FALSE
  OPTIONS_DEBUG
    -DILMBASE_PACKAGE_PREFIX=${CURRENT_INSTALLED_DIR}/debug
  OPTIONS_RELEASE
    -DILMBASE_PACKAGE_PREFIX=${CURRENT_INSTALLED_DIR})

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrenvmap.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrheader.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmakepreview.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmaketiled.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmultipart.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmultiview.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrstdattr.exe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/openexr/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrenvmap.exe ${CURRENT_PACKAGES_DIR}/tools/openexr/exrenvmap.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrheader.exe ${CURRENT_PACKAGES_DIR}/tools/openexr/exrheader.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmakepreview.exe ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmakepreview.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmaketiled.exe ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmaketiled.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmultipart.exe ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmultipart.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmultiview.exe ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmultiview.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrstdattr.exe ${CURRENT_PACKAGES_DIR}/tools/openexr/exrstdattr.exe)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openexr)

vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/include/OpenEXR/ImfExport.h HEADER_FILE)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined(OPENEXR_DLL)" "1" HEADER_FILE "${HEADER_FILE}")
else()
    string(REPLACE "defined(OPENEXR_DLL)" "0" HEADER_FILE "${HEADER_FILE}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/OpenEXR/ImfExport.h "${HEADER_FILE}")

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/OpenEXR)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/OpenEXR/LICENSE ${CURRENT_PACKAGES_DIR}/share/OpenEXR/copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindOpenEXR.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/OpenEXR)

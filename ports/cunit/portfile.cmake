include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CUnit-2.1-3)
vcpkg_download_distfile(ARCHIVE
  URLS "http://downloads.sourceforge.net/project/cunit/CUnit/2.1-3/CUnit-2.1-3.tar.bz2"
  FILENAME "CUnit-2.1-3.tar.bz2"
  SHA512 547b417109332446dfab8fda17bf4ccd2da841dc93f824dc90a20635bcf1fb80fb2176500d8a0906940f3f3d3e2f77b2d70a71090c9ab84ad9af43f3582bc487
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt  ${SOURCE_PATH}/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_build_cmake()

file(GLOB HEADERS  "${SOURCE_PATH}/CUnit/Headers/*.h")
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/cunit)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cunit RENAME copyright)


file(GLOB DLLS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.dll"
)
file(GLOB LIBS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.lib"
)
file(GLOB DEBUG_DLLS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.dll"
)
file(GLOB DEBUG_LIBS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.lib"
)

if(DLLS)
  file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(DEBUG_DLLS)
  file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
vcpkg_copy_pdbs()

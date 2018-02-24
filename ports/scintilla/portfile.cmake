if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic linkage")
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic crt")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/scintilla)
vcpkg_download_distfile(ARCHIVE
  URLS "http://www.scintilla.org/scintilla376.zip"
  FILENAME "scintilla376.zip"
  SHA512 618a50405eede3277d7696ac58122aeeb490d10ae392c60c7f78baaa96c965a8e1a599948e0ebd61bed7f75894b01bdf4574a0e5d0e20996bfdfb2e1bdb33203
)
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

if(TRIPLET_SYSTEM_ARCH MATCHES "x86")
  set(BUILD_ARCH "Win32")
else()
  set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
endif()

vcpkg_build_msbuild(
  PROJECT_PATH ${SOURCE_PATH}/Win32/SciLexer.vcxproj
  PLATFORM ${MSBUILD_PLATFORM}
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include/ILexer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/include/Sci_Position.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/include/SciLexer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/include/Scintilla.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle libraries
if(BUILD_ARCH STREQUAL "Win32")
  set(BUILD_DIR_DEBUG "/Debug")
  set(BUILD_DIR_RELEASE "/Release")
else()
  set(BUILD_DIR_DEBUG "${BUILD_ARCH}/Debug")
  set(BUILD_DIR_RELEASE "${BUILD_ARCH}/Release")
endif()

if(VCPKG_LIBRARY_LINKAGE MATCHES "dynamic")
  file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_RELEASE}/SciLexer.dll  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
  file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_DEBUG}/SciLexer.dll  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_RELEASE}/SciLexer.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_DEBUG}/SciLexer.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# Handle PDBs

file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_RELEASE}/SciLexer.pdb  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_DEBUG}/SciLexer.pdb  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/scintilla RENAME copyright)

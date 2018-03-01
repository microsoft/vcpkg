if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic linkage")
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic crt")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/scintilla)
vcpkg_download_distfile(ARCHIVE
  URLS "http://www.scintilla.org/scintilla403.zip"
  FILENAME "scintilla403.zip"
  SHA512 51704651e99a6b51afff9957676afcf71fa1cc289c1713402c6e50c44a12ec956d5216751ebbbe6f251a23fa8c974510e7c9f37cb66f25f69c30e500e426baad
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

file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_RELEASE}/SciLexer.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_DEBUG}/SciLexer.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_RELEASE}/SciLexer.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_DEBUG}/SciLexer.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# Handle PDBs

file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_RELEASE}/SciLexer.pdb  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${SOURCE_PATH}/win32/${BUILD_DIR_DEBUG}/SciLexer.pdb  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/scintilla RENAME copyright)

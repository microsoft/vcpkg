# This library cannot easily be found only. Be aware that the original source repository is not accessible.
# Checking for updates needs to be done manually by trying to increase the version in the link.
# med-fichier is needed to build all libraries of the https://www.salome-platform.org/ since it is the io 
# entry point to open and read .med files.
vcpkg_download_distfile(ARCHIVE
  URLS "https://files.salome-platform.org/Salome/medfile/med-${VERSION}.tar.gz"
  FILENAME "med-${VERSION}.tar.gz"
  SHA512 f211fa82750a7cc935baa3a50a55d16e40117a0f2254b482492ba8396d82781ca84960995da7a16b2b5be0b93ce76368bf4b311bb8af0e5f0243e7051c9c554c
  HEADERS 
    "Referer: https://www.salome-platform.org/"
)

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE "${ARCHIVE}"
  PATCHES 
    hdf5.patch        # CMake patches for hdf5
    hdf5-2.patch      # source patches to fix API version of HDF5
    more-fixes.patch  # include fixes
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  MEDFILE_BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic"  MEDFILE_BUILD_SHARED_LIBS)

# If there are problems with the cmake build try switching to autotools for !windows
vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE # Writes into the source dir
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DMEDFILE_BUILD_SHARED_LIBS=${MEDFILE_BUILD_SHARED_LIBS}
      -DMEDFILE_BUILD_STATIC_LIBS=${MEDFILE_BUILD_STATIC_LIBS}
      -DMEDFILE_INSTALL_DOC=OFF
      -DMEDFILE_BUILD_TESTS=OFF
      -DCMAKE_Fortran_COMPILER=NOTFOUND # Disable Fortran
    )

vcpkg_cmake_install()
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_cmake_config_fixup(PACKAGE_NAME MEDFile CONFIG_PATH cmake)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/MEDFile/MEDFileConfig.cmake" "/cmake/" "/share/MEDFile/")
else()
  vcpkg_cmake_config_fixup(PACKAGE_NAME MEDFile CONFIG_PATH share/cmake/medfile-4.1.1)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/MEDFile/MEDFileConfig.cmake" "share/cmake/medfile-${VERSION}" "share/MEDFile")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(EXTRA_TOOLS medimport)
endif()

vcpkg_copy_tools(TOOL_NAMES mdump2 mdump3 mdump4 medconforme ${EXTRA_TOOLS} AUTO_CLEAN)
foreach(xdump IN ITEMS xmdump2 xmdump3 xmdump4)
  file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${xdump}" "${CURRENT_PACKAGES_DIR}/debug/bin/${xdump}")
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
elseif(VCPKG_TARGET_IS_WINDOWS) #dynamic builds on windows
  file(GLOB dll_files "${CURRENT_PACKAGES_DIR}/lib/*.dll")
  foreach(dll_file IN LISTS dll_files)
    string(REPLACE "/lib/" "/bin/" dll_file_moved "${dll_file}")
    file(RENAME "${dll_file}" "${dll_file_moved}")
  endforeach()
  if(NOT VCPKG_BUILD_TYPE)
    file(GLOB dll_files "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    foreach(dll_file IN LISTS dll_files)
      string(REPLACE "/lib/" "/bin/" dll_file_moved "${dll_file}")
      file(RENAME "${dll_file}" "${dll_file_moved}")
    endforeach()
  endif()
  set(file "${CURRENT_PACKAGES_DIR}/share/MEDFile/MEDFileTargets-release.cmake")
  file(READ "${file}" contents)
  string(REGEX REPLACE "/lib/([^.]+)\\.dll" "/bin/\\1.dll" contents "${contents}")
  file(WRITE "${file}" "${contents}")
  if(NOT VCPKG_BUILD_TYPE)
    set(file "${CURRENT_PACKAGES_DIR}/share/MEDFile/MEDFileTargets-debug.cmake")
    file(READ "${file}" contents)
    string(REGEX REPLACE "/lib/([^.]+)\\.dll" "/bin/\\1.dll" contents "${contents}")
    file(WRITE "${file}" "${contents}")
  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER") # GPL seems to be mentioned due to autotools stuff

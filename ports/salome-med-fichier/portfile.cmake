# The official release files at files.salome-platform.org reject non-browser
# downloads (HTTP 403 for any non-Mozilla User-Agent, even with a Referer
# header), which breaks vcpkg_download_distfile. The same release sources are
# published as version tags of the upstream repository
# (https://github.com/chennes/med), so the tarball is fetched from there.
# med-fichier is needed to build all libraries of the https://www.salome-platform.org/ since it is the io
# entry point to open and read .med files.
vcpkg_download_distfile(ARCHIVE
  URLS "https://codeload.github.com/chennes/med/tar.gz/refs/tags/v${VERSION}"
  FILENAME "med-${VERSION}.tar.gz"
  SHA512 d3e8820bf9d203f4978a5b7b4bf48286ece30d4f48149adcbe4205470bfe5155cafa7112f5a145f36d3675316ccc4ce8b45c17f406ffafbaf59902c1238479c4
)

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE "${ARCHIVE}"
  PATCHES
    hdf5.patch
    include-io.patch
    quote-paths-in-install-code.diff # Required when CMake is in a path with spaces, e.g. C:\Program Files\CMake\bin\cmake.exe
)

foreach(_source_file IN ITEMS "CMakeLists.txt" "CMakeLists.txt.in")
    vcpkg_replace_string("${SOURCE_PATH}/${_source_file}"
        "SET(INSTALL_CMAKE_CONFIG_DIR "
        "SET(INSTALL_CMAKE_CONFIG_DIR share/MEDFile) #"
    )
endforeach()
foreach(_source_file IN ITEMS "src/CMakeLists.txt" "src/CMakeLists.txt.in" "tools/medimport/CMakeLists.txt" "tools/medimport/CMakeLists.txt.in")
    vcpkg_replace_string("${SOURCE_PATH}/${_source_file}"
        " DESTINATION lib\${LIB_SUFFIX})"
        " DESTINATION lib\${LIB_SUFFIX} RUNTIME DESTINATION bin)"
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  MEDFILE_BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic"  MEDFILE_BUILD_SHARED_LIBS)

# Ensure a host-compatible pkg-config is used. During cross-compilation, the target
# triplet's pkgconf (e.g. arm64) cannot execute on the host. Without this, CMake may
# cache the wrong PKG_CONFIG_EXECUTABLE, breaking find_dependency(MPI) from hdf5-config.
vcpkg_find_acquire_program(PKGCONFIG)

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
      "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    )

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MEDFile)

set(tool_list mdump mdump2 mdump3 mdump4 medconforme)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND tool_list medimport)
endif()

vcpkg_copy_tools(TOOL_NAMES ${tool_list} AUTO_CLEAN)

foreach(xdump_file IN ITEMS xmdump xmdump2 xmdump3 xmdump4)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${xdump_file}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${xdump_file}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/${xdump_file}" "${CURRENT_PACKAGES_DIR}/bin/" [[`dirname $0`/]])
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${xdump_file}")
endforeach()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")


vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER") # GPL seems to be mentioned due to autotools stuff

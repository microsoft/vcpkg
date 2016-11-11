#if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
#    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
#    set(VCPKG_LIBRARY_LINKAGE static)
#endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fmt-3.0.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/fmtlib/fmt/archive/3.0.0.tar.gz"
    FILENAME "fmt-3.0.0.tar.gz"
    SHA512 20c9b1ffe8b46cb5d22015122fc698a75ad854709d3de1a1316b6040d86f54bada4e6d7263f2f1fd94cb13ac37ee9447c162c6aec3f3af650455e8a8a9804871
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)


vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmt RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/bin/fmt.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fmt.dll)

endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/fmt/format.cc)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/fmt/ostream.cc)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/fmt/fmt-targets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake)
file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" FMT_DEBUG_MODULE "${FMT_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

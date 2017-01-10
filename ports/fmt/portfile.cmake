#if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
#    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
#    set(VCPKG_LIBRARY_LINKAGE static)
#endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fmt-3.0.1)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/fmtlib/fmt/archive/3.0.1.tar.gz"
    FILENAME "fmt-3.0.1.tar.gz"
    SHA512 daf5dfb2fe63eb611983fa248bd2182c6202cf1c4f0fc236f357040fce8e87ad531cdf59090306bb313ea333d546e516f467b385e05094e696d0ca091310aad6
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
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
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/fmt/fmt-targets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake)
file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" FMT_DEBUG_MODULE "${FMT_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_DEBUG_MODULE ${FMT_DEBUG_MODULE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake FMT_RELEASE_MODULE)
string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_RELEASE_MODULE ${FMT_RELEASE_MODULE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake "${FMT_RELEASE_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

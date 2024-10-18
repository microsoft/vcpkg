vcpkg_download_distfile(ARCHIVE
    URLS "https://www.riverbankcomputing.com/static/Downloads/QScintilla/${VERSION}/QScintilla_src-${VERSION}.tar.gz"
    FILENAME "QScintilla-${VERSION}.tar.gz"
    SHA512 19e2f9e0a14947501c575018df368d24eb7f8c74e74faa5246db36415bf28dc0beee507ed0e73107c02b36a99bbaf55f0ef3349f479d2332e1b92b2c4a32788a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-static.patch
)

vcpkg_find_acquire_program(PYTHON3)

# Add python3 to path
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

vcpkg_qmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    QMAKE_OPTIONS
        "CONFIG-=hide_symbols"
        "DEFINES+=SCI_NAMESPACE"
)
vcpkg_qmake_install()

file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
if(DLLS)
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE ${DLLS})
endif()

file(GLOB DEBUG_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
if(DEBUG_DLLS)
    file(COPY ${DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE ${DEBUG_DLLS})
endif()

file(GLOB HEADER_FILES ${SOURCE_PATH}/src/Qsci/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/Qsci)

if (VCPKG_TARGET_IS_WINDOWS AND (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic))
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/Qsci/qsciglobal.h
        "#if defined(QSCINTILLA_DLL)"
        "#if 1"
    )
endif()

vcpkg_copy_pdbs()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-qscintilla-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

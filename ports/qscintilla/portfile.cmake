include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/pyqt/files/QScintilla2/QScintilla-2.10/QScintilla_gpl-2.10.zip"
    FILENAME "QScintilla_gpl-2.10.zip"
    SHA512 7c580cfee03af1056f530af756a0ff9cc2396a5419fa23aecc66a6bc8809a4fb154788956220bb0b068a5c214d571c053271c3906d6d541196fbbf7c6dbec917
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_find_acquire_program(PYTHON3)

# Add python3 to path
get_filename_component(PYTHON_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON_PATH})
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)

#Store build paths
set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}/Qt4Qt5
    OPTIONS
        CONFIG+=build_all
        CONFIG-=hide_symbols
        DEFINES+=SCI_NAMESPACE
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_build_qmake(
        RELEASE_TARGETS release
        DEBUG_TARGETS debug
    )
else()
    vcpkg_build_qmake()
endif()

file(GLOB HEADER_FILES ${SOURCE_PATH}/Qt4Qt5/Qsci/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/Qsci)

if(VCPKG_TARGET_IS_WINDOWS)
    configure_file(${RELEASE_DIR}/release/qscintilla2_qt5.lib ${CURRENT_PACKAGES_DIR}/lib/qscintilla2.lib COPYONLY)
    configure_file(${DEBUG_DIR}/debug/qscintilla2_qt5.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qscintilla2.lib COPYONLY)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${RELEASE_DIR}/release/qscintilla2_qt5.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${DEBUG_DIR}/debug/qscintilla2_qt5.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    configure_file(${RELEASE_DIR}/libqscintilla2_qt5.a ${CURRENT_PACKAGES_DIR}/lib/libqscintilla2.a COPYONLY)
    configure_file(${DEBUG_DIR}/libqscintilla2_qt5.a ${CURRENT_PACKAGES_DIR}/debug/lib/libqscintilla2.a COPYONLY)
endif()


vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/qscintilla)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qscintilla/LICENSE ${CURRENT_PACKAGES_DIR}/share/qscintilla/copyright)

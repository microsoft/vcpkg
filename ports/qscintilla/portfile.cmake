vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.riverbankcomputing.com/static/Downloads/QScintilla/2.11.4/QScintilla-2.11.4.tar.gz"
    FILENAME "QScintilla-2.11.4.tar.gz"
    SHA512 90fc2427121ca9ae55e34cf636460099bbdadd844318d9ef05f86790a36e25fb64528264bb7bb99e46b7add96378eff0cc69bb692940c6a1bddfadf86a9abdbd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_find_acquire_program(PYTHON3)

# Add python3 to path
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}/Qt4Qt5
    OPTIONS
        CONFIG+=build_all
        CONFIG-=hide_symbols
        DEFINES+=SCI_NAMESPACE
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_install_qmake(
        RELEASE_TARGETS release
        DEBUG_TARGETS debug
    )
else()
    vcpkg_install_qmake()
endif()

file(GLOB HEADER_FILES ${SOURCE_PATH}/Qt4Qt5/Qsci/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/Qsci)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

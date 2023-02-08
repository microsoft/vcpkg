set(QCP_VERSION 2.1.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${QCP_VERSION}fixed/QCustomPlot.tar.gz"
    FILENAME "QCustomPlot-${QCP_VERSION}.tar.gz"
    SHA512 35ea24529c5a2d984fa6335184a17e90309d8e58d7d75e2a8d0ccb5cb1d7ac7bd16e157d5f625736cfe37f2aa8bf38d698058a8a746781876fa051cea2ffc765
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF "${QCP_VERSION}"
    PATCHES fix_qt6_build.patch
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${QCP_VERSION}fixed/QCustomPlot-sharedlib.tar.gz"
    FILENAME "QCustomPlot-sharedlib-${QCP_VERSION}.tar.gz"
    SHA512 5736bff85eab41d9505489c184f38aa5fd5fab84730349a73122fd6cb4f6c283b16425905522d6b37918d70cb2984636b9f64fc9ecf41aa586fe9f3580671314
)
vcpkg_extract_source_archive(SharedLib_SOURCE_PATH ARCHIVE "${ARCHIVE}")
file(RENAME "${SharedLib_SOURCE_PATH}" "${SOURCE_PATH}/qcustomplot-sharedlib/")
set(pro_file "${SOURCE_PATH}/qcustomplot-sharedlib/sharedlib-compilation/sharedlib-compilation.pro")
vcpkg_replace_string("${pro_file}" "CONFIG += debug_and_release build_all" "")


file(READ "${pro_file}" pro_string)
string(APPEND pro_string [[
win32 {
    dlltarget.path = $$[QT_INSTALL_BINS]
    INSTALLS += dlltarget
}
target.path    = $$[QT_INSTALL_LIBS]
!static: target.CONFIG = no_dll
INSTALLS     += target

headers.files += ../../qcustomplot.h
headers.path = $$[QT_INSTALL_PREFIX]/include
INSTALLS     += headers
]])
file(WRITE "${pro_file}" "${pro_string}")

vcpkg_qmake_configure(SOURCE_PATH
                        "${SOURCE_PATH}/qcustomplot-sharedlib/sharedlib-compilation"
                      QMAKE_OPTIONS
                        "QT+=opengl"
                        "CONFIG+=create_prl"
                        "DEFINES+=QCUSTOMPLOT_USE_OPENGL"
                        )
vcpkg_qmake_install()

vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/qcustomplot.h" "#ifdef QCUSTOMPLOT_USE_OPENGL" "#define QCUSTOMPLOT_USE_OPENGL\n#ifdef QCUSTOMPLOT_USE_OPENGL")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/qcustomplot.h" "#if defined(QT_STATIC_BUILD)" "#if 1")
endif()

# Handle copyright
configure_file("${SOURCE_PATH}/GPL.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

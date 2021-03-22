vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gtkmm/4.0/gtkmm-4.0.0.tar.xz"
    FILENAME "gtkmm-4.0.0.tar.xz"
    SHA512 16893b6caa39f1b65a4140296d8d25c0d5e5f8a6ab808086783e7222bc1f5e8b94d17d48e4b718a12f0e0291010d445f4da9f88b7f494ec36adb22752d932743
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix_properties.patch
        fix_treeviewcolumn.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/msvc_recommended_pragmas.h DESTINATION ${SOURCE_PATH}/MSVC_Net2013)

set(VS_PLATFORM ${VCPKG_TARGET_ARCHITECTURE})
if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)
    set(VS_PLATFORM "Win32")
endif(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/MSVC_Net2013/gtkmm.sln
    TARGET gtkmm
    PLATFORM ${VS_PLATFORM}
    USE_VCPKG_INTEGRATION
)

# Handle headers
file(COPY ${SOURCE_PATH}/MSVC_Net2013/gdkmm/gdkmmconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/gdk/gdkmm.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(
    COPY
    ${SOURCE_PATH}/gdk/gdkmm
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    FILES_MATCHING PATTERN *.h
)
file(COPY ${SOURCE_PATH}/MSVC_Net2013/gtkmm/gtkmmconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/gtk/gtkmm.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(
    COPY
    ${SOURCE_PATH}/gtk/gtkmm
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    FILES_MATCHING PATTERN *.h
)

# Handle libraries
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/gdkmm.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/gdkmm.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/gtkmm.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/gtkmm.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/gdkmm.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/gdkmm.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/gtkmm.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/gtkmm.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

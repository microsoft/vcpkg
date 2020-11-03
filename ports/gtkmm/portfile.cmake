if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/gtkmm/3.22/gtkmm-3.22.2.tar.xz"
    FILENAME "gtkmm-3.22.2.tar.xz"
    SHA512 6e96b543e459481145ee0f56f31a7ad2466bd8ccdd2abf3205998aecede73d235149ca6e5ba6e8d20a4fd5345e310870d81ac2a716d4f78d1460ed685badbdc2
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

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtkmm RENAME copyright)

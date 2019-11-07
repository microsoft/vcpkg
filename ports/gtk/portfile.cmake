set(GTK_VERSION 3.22.19)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/gtk+/3.22/gtk+-${GTK_VERSION}.tar.xz"
    FILENAME "gtk+-${GTK_VERSION}.tar.xz"
    SHA512 c83198794433ee6eb29f8740d59bd7056cd36808b4bff1a99563ab1a1742e6635dab4f2a8be33317f74d3b336f0d1adc28dd91410da056b50a08c215f184dce2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES fix-win-build.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
    
    vcpkg_find_acquire_program(PYTHON3)
    
    set(GTK_PROPS_FILE ${SOURCE_PATH}/build/win32/vs15/gtk3-version-paths.props)
    set(GTK_PROPS_FILE_BAK ${SOURCE_PATH}/build/win32/vs15/gtk3-version-paths.props.bak)
    # Bakup prop file
    if (NOT EXISTS ${GTK_PROPS_FILE_BAK})
        configure_file(${GTK_PROPS_FILE} ${GTK_PROPS_FILE_BAK} COPYONLY)
    endif()
    # Set install path
    configure_file(${GTK_PROPS_FILE_BAK} ${GTK_PROPS_FILE} COPYONLY)
    file(READ ${GTK_PROPS_FILE} GTK_PROPS)
    file(TO_NATIVE_PATH ${CURRENT_PACKAGES_DIR} NATIVE_PATH_REL)
    file(TO_NATIVE_PATH ${CURRENT_PACKAGES_DIR}/debug NATIVE_PATH_DBG)
    string(REPLACE "<CopyDir>..\\..\\..\\..\\vs$(VSVer)\\$(Platform)<\/CopyDir>"
                "<CopyDir Condition=\"\'$(Configuration)|$(Platform)\'==\'Release|Win32\' Or \'$(Configuration)|$(Platform)\'==\'Release|x64\'\">${NATIVE_PATH_REL}<\/CopyDir>\r\n    <CopyDir Condition=\"\'$(Configuration)|$(Platform)\'==\'Debug|Win32\' Or \'$(Configuration)|$(Platform)\'==\'Debug|x64\'\">${NATIVE_PATH_DBG}<\/CopyDir>"
                GTK_PROPS "${GTK_PROPS}"
    )
    file(WRITE ${GTK_PROPS_FILE} "${GTK_PROPS}")
    
    # generate sources using python script installed with glib
    set(GLIB_TOOL_DIR ${CURRENT_INSTALLED_DIR}/tools/glib)
    message("Generating GTK+ DBus Sources...")
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ${GLIB_TOOL_DIR}/gdbus-codegen --interface-prefix org.Gtk. --c-namespace _Gtk --generate-c-code gtkdbusgenerated ./gtkdbusinterfaces.xml
        WORKING_DIRECTORY ${SOURCE_PATH}/gtk
        LOGNAME source-gen
    )
    
    # generate manifest
    message("Generating GTK+ Win32 Manifest...")
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ../replace.py --action=replace-var --input=../../../gtk/libgtk3.manifest.in --output=../../../gtk/libgtk3.manifest --var=EXE_MANIFEST_ARCHITECTURE --outstring=*
        WORKING_DIRECTORY ${SOURCE_PATH}/build/win32/vs15
        LOGNAME manifest-gen
    )
    
    if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(BUILD_ARCH "Win32")
    elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(BUILD_ARCH "x64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/build/win32/vs15/gtk+.sln
        PLATFORM ${BUILD_ARCH}
        USE_VCPKG_INTEGRATION
    )

    message("Compiling gsettings XML Files...")
    # Since glib-compile-schemas.exe requires link dependencies, these dlls are temporarily needs to copy.
    set(TEMP_USE_DLL ${CURRENT_INSTALLED_DIR}/bin/libintl.dll
                     ${CURRENT_INSTALLED_DIR}/bin/gdk_pixbuf-2.dll
                     ${CURRENT_INSTALLED_DIR}/bin/glib-2.dll
                     ${CURRENT_INSTALLED_DIR}/bin/pcre.dll
                     ${CURRENT_INSTALLED_DIR}/bin/libiconv.dll
                     ${CURRENT_INSTALLED_DIR}/bin/libcharset.dll
    )
    file(COPY ${TEMP_USE_DLL} ${CURRENT_INSTALLED_DIR}/tools/glib/glib-compile-schemas.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tmp/tools)
    vcpkg_execute_required_process(
        COMMAND ${CURRENT_PACKAGES_DIR}/tmp/tools/glib-compile-schemas.exe ${CURRENT_PACKAGES_DIR}/share/glib-2.0/schemas
        WORKING_DIRECTORY ${SOURCE_PATH}/build/win32/vs15
        LOGNAME xml-gen
    )
    # Remove these dependencies
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tmp)
    
    message("Generating icon cache......")
    # temporarily copy these dependencies.
    list(APPEND TEMP_USE_DLL ${CURRENT_INSTALLED_DIR}/bin/gio-2.dll
                             ${CURRENT_INSTALLED_DIR}/bin/gmodule-2.dll
                             ${CURRENT_INSTALLED_DIR}/bin/gobject-2.dll
                             ${CURRENT_INSTALLED_DIR}/bin/libpng16.dll
                             ${CURRENT_INSTALLED_DIR}/bin/zlib1.dll
    )
    file(COPY ${TEMP_USE_DLL} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    vcpkg_execute_required_process(
        COMMAND ${CURRENT_PACKAGES_DIR}/bin/gtk-update-icon-cache.exe --ignore-theme-index --force "${CURRENT_PACKAGES_DIR}/share/icons/hicolor"
        WORKING_DIRECTORY ${SOURCE_PATH}/build/win32/vs15
        LOGNAME icno-gen
    )
    # Remove these dependencies
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libintl.dll
                ${CURRENT_PACKAGES_DIR}/bin/gdk_pixbuf-2.dll
                ${CURRENT_PACKAGES_DIR}/bin/glib-2.dll
                ${CURRENT_PACKAGES_DIR}/bin/pcre.dll
                ${CURRENT_PACKAGES_DIR}/bin/libiconv.dll
                ${CURRENT_PACKAGES_DIR}/bin/libcharset.dll
                ${CURRENT_PACKAGES_DIR}/bin/gio-2.dll
                ${CURRENT_PACKAGES_DIR}/bin/gmodule-2.dll
                ${CURRENT_PACKAGES_DIR}/bin/gobject-2.dll
                ${CURRENT_PACKAGES_DIR}/bin/libpng16.dll
                ${CURRENT_PACKAGES_DIR}/bin/zlib1.dll
    )
    
    message("Generating .pc files...")
    if (VCPKG_PLATFORM_TOOLSET STREQUAL v140)
        set(VS_VER 15)
    elseif (VCPKG_PLATFORM_TOOLSET STREQUAL v141)
        set(VS_VER 17)
    elseif (VCPKG_PLATFORM_TOOLSET STREQUAL v142)
        set(VS_VER 19)
    else()
        set(VS_VER unknow)
    endif()
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ../gtkpc.py --prefix=${CURRENT_PACKAGES_DIR} --version=${GTK_VERSION} --host=i686-pc-vs${VS_VER}
        WORKING_DIRECTORY ${SOURCE_PATH}/build/win32/vs15
        LOGNAME pc-gen
    )
    
    # Install tools
    if (NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL release)
        file(GLOB_RECURSE GTK_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
        foreach (GTK_TOOL ${GTK_TOOLS})
            get_filename_component(TOOL_NAME ${GTK_TOOL} NAME_WE)
            file(INSTALL ${GTK_TOOL} ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gtk)
            file(REMOVE ${GTK_TOOL} ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}.pdb)
        endforeach()
    endif()
    if (NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL debug)
        file(GLOB_RECURSE GTK_TOOLS ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
        foreach (GTK_TOOL ${GTK_TOOLS})
            get_filename_component(TOOL_NAME ${GTK_TOOL} NAME_WE)
            file(INSTALL ${GTK_TOOL} ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/gtk)
            file(REMOVE ${GTK_TOOL} ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}.pdb)
        endforeach()
    endif()
    
    # Install pkgconfig
    file(INSTALL ${SOURCE_PATH}/build/win32/gdk-3.0.pc DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig RENAME gdk-win32-3.0.pc)
    file(INSTALL ${SOURCE_PATH}/build/win32/gdk-3.0.pc DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig RENAME gdk-win32-3.0.pc)
    file(INSTALL ${SOURCE_PATH}/build/win32/gtk+-3.0.pc DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
    file(INSTALL ${SOURCE_PATH}/build/win32/gtk+-3.0.pc DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
else()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})
    
    # generate sources using python script installed with glib
    if(NOT EXISTS ${SOURCE_PATH}/gtk/gtkdbusgenerated.h OR NOT EXISTS ${SOURCE_PATH}/gtk/gtkdbusgenerated.c)
        vcpkg_find_acquire_program(PYTHON3)
        set(GLIB_TOOL_DIR ${CURRENT_INSTALLED_DIR}/tools/glib)
    
        vcpkg_execute_required_process(
            COMMAND ${PYTHON3} ${GLIB_TOOL_DIR}/gdbus-codegen --interface-prefix org.Gtk. --c-namespace _Gtk --generate-c-code gtkdbusgenerated ./gtkdbusinterfaces.xml
            WORKING_DIRECTORY ${SOURCE_PATH}/gtk
            LOGNAME source-gen)
    endif()
    
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DGTK_VERSION=${GTK_VERSION}
        OPTIONS_DEBUG
            -DGTK_SKIP_HEADERS=ON)
    
    vcpkg_install_cmake()
    vcpkg_copy_pdbs()
endif()
    
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

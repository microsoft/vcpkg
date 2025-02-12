vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF ${VERSION}
    SHA512 697205a571bb3d52d83598e8511e2e21e7cd15630aac32d8deb4354e462efda6a5ce46510cf4a1c18365dffe935cf2e4f1fda65d1779f17c9bb60c503315bf5c
    HEAD_REF master
    PATCHES
        fix-win32-build.patch
        fix-build-ffmpeg-failed.patch
)

if("icu" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dicu=enabled) # Enable ICU library unicode functions
else()
    list(APPEND FEATURE_OPTIONS -Dicu=disabled)
endif()
if("graphite2" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dgraphite=enabled) #Enable Graphite2 complementary shaper
else()
    list(APPEND FEATURE_OPTIONS -Dgraphite=disabled)
endif()
if("coretext" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dcoretext=enabled) # Enable CoreText shaper backend on macOS
else()
    list(APPEND FEATURE_OPTIONS -Dcoretext=disabled)
endif()
if("directwrite" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Ddirectwrite=enabled) # Enable DirectWrite support on Windows
else()
    list(APPEND FEATURE_OPTIONS -Ddirectwrite=disabled)
endif()
if("glib" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dglib=enabled) # Enable GLib unicode functions
    list(APPEND FEATURE_OPTIONS -Dgobject=enabled) #Enable GObject bindings
    list(APPEND FEATURE_OPTIONS -Dchafa=disabled)
else()
    list(APPEND FEATURE_OPTIONS -Dglib=disabled)
    list(APPEND FEATURE_OPTIONS -Dgobject=disabled)
endif()
if("cairo" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dcairo=enabled) # Enable Cairo graphics library support
else()
    list(APPEND FEATURE_OPTIONS -Dcairo=disabled)
endif()
if("freetype" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dfreetype=enabled) #Enable freetype interop helpers
else()
    list(APPEND FEATURE_OPTIONS -Dfreetype=disabled)
endif()
if("experimental-api" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dexperimental_api=true) #Enable experimental api
else()
    list(APPEND FEATURE_OPTIONS -Dexperimental_api=false)
endif()
if("gdi" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dgdi=enabled) # enable gdi helpers and uniscribe shaper backend (windows only)
endif()

if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_DEBUG -Dgobject=enabled -Dintrospection=disabled)
    list(APPEND OPTIONS_RELEASE -Dgobject=enabled -Dintrospection=enabled)
else()
    list(APPEND OPTIONS -Dintrospection=disabled)
endif()

if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(GIR_TOOL_DIR ${CURRENT_INSTALLED_DIR})
else()
    set(GIR_TOOL_DIR ${CURRENT_HOST_INSTALLED_DIR})
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Ddocs=disabled          # Generate documentation with gtk-doc
        -Dtests=disabled
        -Dbenchmark=disabled
        ${OPTIONS}
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        g-ir-compiler='${GIR_TOOL_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${GIR_TOOL_DIR}/tools/gobject-introspection/g-ir-scanner'
)

vcpkg_install_meson(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
	file(GLOB PC_FILES 
		"${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc" 
		"${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
	
	foreach(PC_FILE IN LISTS PC_FILES)
		file(READ "${PC_FILE}" PC_FILE_CONTENT)
		string(REGEX REPLACE 
			"\\$\\{prefix\}\\/lib\\/([a-zA-Z0-9\-]*)\\.lib" 
			"-l\\1" PC_FILE_CONTENT 
			"${PC_FILE_CONTENT}")
		file(WRITE "${PC_FILE}" ${PC_FILE_CONTENT})
	endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
configure_file("${CMAKE_CURRENT_LIST_DIR}/harfbuzzConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/harfbuzzConfig.cmake" @ONLY)

vcpkg_list(SET TOOL_NAMES)
if("glib" IN_LIST FEATURES)
    vcpkg_list(APPEND TOOL_NAMES hb-subset hb-shape hb-ot-shape-closure hb-info)
    if("cairo" IN_LIST FEATURES)
        vcpkg_list(APPEND TOOL_NAMES hb-view)
    endif()
endif()
if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

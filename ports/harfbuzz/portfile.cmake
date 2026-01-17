vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF ${VERSION}
    SHA512 b8f0acf2d25abd64881b4dcef52d0a2d43eefd9ead6833878b5183f38bcac8659b9c6c26358dd0624b4f6633da4c3a536f60bcf8b471d451a518dec45fd44f7a
    HEAD_REF master
    PATCHES
        fix-win32-build.patch
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
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND OPTIONS -Dintrospection=disabled)
endif()

set(cxx_link_libraries "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    block(PROPAGATE cxx_link_libraries)
        vcpkg_list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_DEFAULT_VARS_TO_CHECK=CMAKE_C_IMPLICIT_LINK_LIBRARIES;CMAKE_CXX_IMPLICIT_LINK_LIBRARIES")
        vcpkg_cmake_get_vars(cmake_vars_file)
        include("${cmake_vars_file}")
        list(REMOVE_ITEM VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES ${VCPKG_DETECTED_CMAKE_C_IMPLICIT_LINK_LIBRARIES})
        list(TRANSFORM VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES PREPEND "-l")
        string(JOIN " " cxx_link_libraries ${VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
    endblock()
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
        g-ir-compiler='${GIR_COMPILER}'
        g-ir-scanner='${GIR_SCANNER}'
)

vcpkg_install_meson(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(cxx_link_libraries)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/harfbuzz.pc"
        "(Libs:[^\r\n]*)"
        "\\1 ${cxx_link_libraries}"
        REGEX
    )
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/harfbuzz.pc"
            "(Libs:[^\r\n]*)"
            "\\1 ${cxx_link_libraries}"
            REGEX
        )
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB pc_files
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc"
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc"
    )
    foreach(pc_file IN LISTS pc_files)
        vcpkg_replace_string("${pc_file}"
            "\\$\\{prefix\}\\/lib\\/([a-zA-Z0-9\-]*)\\.lib"
            "-l\\1"
            REGEX
            IGNORE_UNCHANGED
        )
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
configure_file("${CMAKE_CURRENT_LIST_DIR}/harfbuzzConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/harfbuzzConfig.cmake" @ONLY)

vcpkg_list(SET TOOL_NAMES)
if("glib" IN_LIST FEATURES)
    vcpkg_list(APPEND TOOL_NAMES hb-subset hb-shape hb-info)
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

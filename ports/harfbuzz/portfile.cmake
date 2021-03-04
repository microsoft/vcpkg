vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 7236c7e29cef1c2d76c7a284c5081ff4d3aa1127 # 2.7.4
    SHA512 d231a788ea4e52231d4c363c1eca76424cb82ed0952b5c24d0b082e88b3dddbda967e7fffe67fffdcb22c7ebfbf0ec923365eb4532be772f2e61fa7d29b51998
    HEAD_REF master
    PATCHES 0002-fix-uwp-build.patch
)

if("icu" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dicu=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dicu=disabled)
endif()
if("graphite2" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dgraphite=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dgraphite=disabled)
endif()
if("glib" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dglib=enabled)
    list(APPEND FEATURE_OPTIONS -Dgobject=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dglib=disabled)
    list(APPEND FEATURE_OPTIONS -Dgobject=disabled)
endif()
list(APPEND FEATURE_OPTIONS -Dfreetype=enabled)
#if(VCPKG_TARGET_IS_WINDOWS)
#    list(APPEND FEATURE_OPTIONS -Dgdi=enabled) # This breaks qt5-base:x64-windows-static due to missing libraries being link against. 
#elseif(VCPKG_TARGET_IS_OSX)
#    list(APPEND FEATURE_OPTIONS -Dcoretext=enabled)
#endif()


vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -Dcairo=disabled
        -Dfontconfig=disabled
        -Dintrospection=disabled
        -Ddocs=disabled
        -Dtests=disabled
        -Dbenchmark=disabled
    ADDITIONAL_NATIVE_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                                glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES   glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                                glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
configure_file("${CMAKE_CURRENT_LIST_DIR}/harfbuzzConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/harfbuzzConfig.cmake" @ONLY)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if("glib" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES hb-subset hb-shape hb-ot-shape-closure)
endif()
if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# # HarfBuzz feature options
# option('glib', type: 'feature', value: 'auto',
  # description: 'Enable GLib unicode functions')
# option('gobject', type: 'feature', value: 'auto',
  # description: 'Enable GObject bindings')
# option('cairo', type: 'feature', value: 'auto',
  # description: 'Use Cairo graphics library')
# option('fontconfig', type: 'feature', value: 'auto',
  # description: 'Use fontconfig')
# option('icu', type: 'feature', value: 'auto',
  # description: 'Enable ICU library unicode functions')
# option('graphite', type: 'feature', value: disabled,
  # description: 'Enable Graphite2 complementary shaper')
# option('freetype', type: 'feature', value: 'auto',
  # description: 'Enable freetype interop helpers')
# option('gdi', type: 'feature', value: disabled,
  # description: 'Enable GDI helpers and Uniscribe shaper backend (Windows only)')
# option('directwrite', type: 'feature', value: disabled,
  # description: 'Enable DirectWrite shaper backend on Windows (experimental)')
# option('coretext', type: 'feature', value: disabled,
  # description: 'Enable CoreText shaper backend on macOS')

# # Common feature options
# option('tests', type: 'feature', value: enabled, yield: true,
  # description: 'Enable or disable unit tests')
# option('introspection', type: 'feature', value: 'auto', yield: true,
  # description: 'Generate gobject-introspection bindings (.gir/.typelib files)')
# option('docs', type: 'feature', value: 'auto', yield: true,
  # description: 'Generate documentation with gtk-doc')

# option('benchmark', type: 'feature', value: 'auto',
  # description: 'Enable benchmark tests')
# option('icu_builtin', type: 'boolean', value: false,
  # description: 'Don\'t separate ICU support as harfbuzz-icu module')
# option('experimental_api', type: 'boolean', value: false,
  # description: 'Enable experimental APIs')
# option('fuzzer_ldflags', type: 'string',
  # description: 'Extra LDFLAGS used during linking of fuzzing binaries')
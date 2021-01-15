vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 7236c7e29cef1c2d76c7a284c5081ff4d3aa1127 # 2.7.4
    SHA512 d231a788ea4e52231d4c363c1eca76424cb82ed0952b5c24d0b082e88b3dddbda967e7fffe67fffdcb22c7ebfbf0ec923365eb4532be772f2e61fa7d29b51998
    HEAD_REF master
    PATCHES
        0002-fix-uwp-build.patch
        0003-remove-broken-test.patch
        CMakeLists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    icu         HB_HAVE_ICU
    graphite2   HB_HAVE_GRAPHITE2
    glib        HB_HAVE_GLIB
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS -DHP_HAVE_GDI=ON)
endif()
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DHB_HAVE_FREETYPE=ON
        -DHB_BUILD_TESTS=OFF
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)
vcpkg_install_cmake()

# if("icu" IN_LIST FEATURES)
    # list(APPEND FEATURE_OPTIONS -Dicu=enabled)
# else()
    # list(APPEND FEATURE_OPTIONS -Dicu=disabled)
# endif()
# if("graphite2" IN_LIST FEATURES)
    # list(APPEND FEATURE_OPTIONS -Dgraphite=enabled)
# else()
    # list(APPEND FEATURE_OPTIONS -Dgraphite=disabled)
# endif()
# if("glib" IN_LIST FEATURES)
    # list(APPEND FEATURE_OPTIONS -Dglib=enabled)
    # list(APPEND FEATURE_OPTIONS -Dgobject=enabled)
# else()
    # list(APPEND FEATURE_OPTIONS -Dglib=disabled)
    # list(APPEND FEATURE_OPTIONS -Dgobject=disabled)
# endif()
# list(APPEND FEATURE_OPTIONS -Dfreetype=enabled)
# if(VCPKG_TARGET_IS_WINDOWS)
    # list(APPEND FEATURE_OPTIONS -Dgdi=enabled)
# endif()
# vcpkg_configure_meson(
    # SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA
    # OPTIONS ${FEATURE_OPTIONS}
            # -Dtests=disabled
            # -Dintrospection=disabled
            # -Ddocs=disabled
            # -Dbenchmark=disabled
            # -Dfontconfig=disabled
# )
# vcpkg_install_meson()

vcpkg_fixup_pkgconfig()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()


# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


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
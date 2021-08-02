vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO neXyon/audaspace
    REF b73dc6d0c8930137a6dde582979a5038a4417701
    SHA512 ee47549411d50c7a648cf3c01b9e05d3f63cfbc346a664b71f5f21a1b491825641dcc4f676dd7a5f0ff24eef7445577df7c486ddf08e090f8956135377bb466a
    HEAD_REF master
    PATCHES
        0001-Remove-C-CXX-flags.patch
        0002-Fix-install-directories.patch
        0003-Always-export-pkgconfig-file.patch
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ffmpeg     WITH_FFMPEG
        openal     WITH_OPENAL
        pulseaudio WITH_PULSEAUDIO
        sdl        WITH_SDL
)

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    set(PLUGIN_PATH "bin")
else()
    set(PLUGIN_PATH "lib")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DEMOS=OFF
        -DCMAKE_C_VISIBILITY_PRESET=hidden
        -DCMAKE_CXX_VISIBILITY_PRESET=hidden
        -DDEFAULT_PLUGIN_PATH=${PLUGIN_PATH}
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
        -DWITH_DOCS=OFF
        -DWITH_JACK=OFF
        -DWITH_PYTHON=OFF
        -DWITH_SDL=OFF
        -DWITH_STRICT_DEPENDENCIES=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Plugin import libraries are not needed by consumers.
file(
    GLOB _PLUGIN_LIBS
    "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}"
    "${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}"
)
if(_PLUGIN_LIBS)
    file(REMOVE ${_PLUGIN_LIBS})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

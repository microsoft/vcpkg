vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liballeg/allegro5
    REF 5.2.6.0
    SHA512 d590c1a00d1b314c6946e0f6ad3e3a8b6e6309bada2ec38857186f817147ac99dae8a1c4412abe701af88da5dca3dd8f989a1da66630192643d3c08c0146b603
    HEAD_REF master
    PATCHES
        do-not-copy-pdbs-to-lib.patch
        export-targets.patch
        msvc-arm64-atomic.patch
)


string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" VCPKG_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DWANT_DOCS=OFF
        -DALLEGRO_SDL=OFF
        -DWANT_DEMO=OFF
        -DSHARED=${VCPKG_BUILD_SHARED_LIBS}
        -DINSTALL_PKG_CONFIG_FILES=true
        -DWANT_EXAMPLES=OFF
        -DWANT_TESTS=OFF
        -DWANT_AUDIO=ON
        -DWANT_COLOR=ON
        -DWANT_D3D=ON
        -DWANT_D3D9EX=OFF # Not available on vcpkg
        -DWANT_DSOUND=ON
        -DWANT_FLAC=ON
        -DWANT_FONT=ON
        -DWANT_GLES3=ON
        -DWANT_IMAGE=ON
        -DWANT_IMAGE_JPG=ON
        -DWANT_IMAGE_PNG=ON
        -DWANT_MEMFILE=ON
        -DWANT_MODAUDIO=OFF # Not available on vcpkg right now
        -DWANT_NATIVE_DIALOG=ON
        -DWANT_NATIVE_IMAGE_LOADER=ON
        -DWANT_OGG_VIDEO=ON
        -DWANT_OPENAL=ON
        -DWANT_OPENGL=ON
        -DWANT_OPENSL=OFF # Not yet available on vcpkg
        -DWANT_OPUS=ON
        -DWANT_PHYSFS=ON
        -DWANT_POPUP_EXAMPLES=OFF
        -DWANT_PRIMITIVES=ON
        -DWANT_RELEASE_LOGGING=OFF
        -DWANT_SHADERS_D3D=ON
        -DWANT_SHADERS_GL=ON
        -DWANT_TREMOR=OFF # Not yet available on vcpkg
        -DWANT_TTF=ON
        -DWANT_VIDEO=ON
        -DWANT_VORBIS=ON
    OPTIONS_RELEASE
        -DWANT_ALLOW_SSE=ON
    OPTIONS_DEBUG
        -DWANT_ALLOW_SSE=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-allegro5 CONFIG_PATH share/unofficial-allegro5)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

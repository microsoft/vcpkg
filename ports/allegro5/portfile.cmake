vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liballeg/allegro5
    REF ${VERSION}
    SHA512 2e7833b725718fdf11f1cd5999dc9fafca4b34adda15d3d8cb551c0eb00368d2e1c08b15f8beb766e2f208ffdc3b5e33175e969c7333ad6dc92f269522ac3d32
    HEAD_REF master
    PATCHES
        do-not-copy-pdbs-to-lib.patch
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

vcpkg_cmake_config_fixup(PACKAGE_NAME allegro CONFIG_PATH lib/cmake/allegro)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

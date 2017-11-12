# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liballeg/allegro5
    REF e8b209bc20a60224859eb8a0cae082bd20d32ed1
    SHA512 50b30d4b539bd4a2488d2b33e9fbfc6fdfd340039d9086993a5719bab3cb020ee6fe7f6d3578755a52c8aab9816d25cd74710ce93b0b374a2f97620b6138419d
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(ALLEGRO_USE_STATIC ON)
else()
    set(ALLEGRO_USE_STATIC OFF)
endif()

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-pdb-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DWANT_DOCS=OFF
        -DALLEGRO_SDL=OFF
        -DWANT_DEMO=OFF
        -DSHARED=${ALLEGRO_USE_STATIC}
        -DWANT_EXAMPLES=OFF
        -DWANT_CURL_EXAMPLE=OFF
        -DWANT_TESTS=OFF
        -DWANT_AUDIO=ON
        -DWANT_COLOR=ON
        -DWANT_D3D=ON
        -DWANT_D3D9EX=OFF # Not available on vcpkg
        -DWANT_DSOUND=ON
        -DWANT_FLAC=ON
        -DWANT_FONT=ON
        -DWANT_GLES2=ON
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
        -DOPENAL_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/AL
        -DZLIB_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
    OPTIONS_RELEASE -DWANT_ALLOW_SSE=ON
    OPTIONS_DEBUG -DWANT_ALLOW_SSE=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/allegro5)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/allegro5/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/allegro5/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB PDB_GLOB ${CURRENT_BUILDTREES_DIR}-dbg/lib/*.pdb)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}-dbg/lib/Debug)
file(COPY ${PDB_GLOB} DESTINATION ${CURRENT_BUILDTREES_DIR}-dbg/lib/Debug)

vcpkg_copy_pdbs()

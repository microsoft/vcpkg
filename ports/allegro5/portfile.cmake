include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liballeg/allegro5
    REF 5.2.5.0
    SHA512 9b97a46f0fd146c3958a5f8333822665ae06b984b3dbedc1356afdac8fe3248203347cb08b30ebda049a7320948c7844e9d00dc055c317836c2557b5bfc2ab04
    HEAD_REF master
    PATCHES
        fix-pdb-install.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWANT_DOCS=OFF
        -DALLEGRO_SDL=OFF
        -DWANT_DEMO=OFF
        -DSHARED=${VCPKG_BUILD_SHARED_LIBS}
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB PDB_GLOB ${CURRENT_BUILDTREES_DIR}-dbg/lib/*.pdb)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}-dbg/lib/Debug)
file(COPY ${PDB_GLOB} DESTINATION ${CURRENT_BUILDTREES_DIR}-dbg/lib/Debug)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/allegro5 RENAME copyright)

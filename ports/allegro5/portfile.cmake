vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liballeg/allegro5
    REF "${VERSION}"
    SHA512 fe9a1c28824b88d34045cf3a296a5671f5b6992f881678bbeb5290ec220138ab9bd3608fa241539d39a2c6eec32ef267d31f2694a4c5b06d13164eead6a13a5b
    HEAD_REF master
    PATCHES
        do-not-copy-pdbs-to-lib.patch
        msvc-arm64-atomic.patch
        minimp3-fix.patch
        android-glext-prototypes.diff
        skip-android-aar.diff          # Building AAR, not needed for vcpkg
)

if(VCPKG_TARGET_IS_ANDROID AND "$ENV{ANDROID_HOME}" STREQUAL "")
    message(FATAL_ERROR "${PORT} requires environment variable ANDROID_HOME to be set.")
endif()

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" VCPKG_BUILD_SHARED_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        direct3d    WANT_D3D
        opengl      WANT_OPENGL
)
if(NOT WANT_OPENGL)
    list(APPEND options -DWANT_X11=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DINSTALL_PKG_CONFIG_FILES=true
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
        -DSHARED=${VCPKG_BUILD_SHARED_LIBS}
        ${options}
        -DALLEGRO_SDL=OFF
        -DWANT_D3D9EX=OFF # Not available on vcpkg
        -DWANT_DEMO=OFF
        -DWANT_DOCS=OFF
        -DWANT_EXAMPLES=OFF
        -DWANT_GLES3=ON
        -DWANT_IMAGE_FREEIMAGE=OFF
        -DWANT_MODAUDIO=OFF # Not available on vcpkg right now
        -DWANT_MP3=ON
        -DWANT_OPENSL=OFF # Not yet available on vcpkg
        -DWANT_POPUP_EXAMPLES=OFF
        -DWANT_TESTS=OFF
        -DWANT_TREMOR=OFF # Not yet available on vcpkg
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_USE_CMAKE_PREFIX_PATH
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/allegro)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

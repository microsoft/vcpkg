# https://miktex.org/howto/build-win

include(vcpkg_common_functions)

find_program(NMAKE nmake REQUIRED)
# Use nmake to build

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MiKTeX/miktex
    REF 2.9.6600
    SHA512 d09ad76504c2cb36cd61e57657e420f5c6ad92af5069ca3fb2d6aabfd0c86e08595c3ec02f0b7ea106e4a24e2dc64c9c357986959846f2753baf1afd6aa2d85d
    HEAD_REF master
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils sed libxslt)
set(ENV{PATH} "$ENV{PATH};${MSYS_ROOT}/usr/bin")

vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_EXE_PATH ${BISON} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${BISON_EXE_PATH}")
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_EXE_PATH ${FLEX} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${FLEX_EXE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA
    GENERATOR "NMake Makefiles"
    OPTIONS
        -DWITH_UI_MFC=OFF
        -DWITH_COM=OFF
        -DWITH_MIKTEX_DOC=OFF
        -DWITH_UI_QT=OFF
)

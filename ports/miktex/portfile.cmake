# https://miktex.org/howto/build-win

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MiKTeX/miktex
    REF 2.9.6600
    SHA512 d09ad76504c2cb36cd61e57657e420f5c6ad92af5069ca3fb2d6aabfd0c86e08595c3ec02f0b7ea106e4a24e2dc64c9c357986959846f2753baf1afd6aa2d85d
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-msc-ver.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-cmake-find.patch
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils sed libxslt)
set(ENV{PATH} "$ENV{PATH};${MSYS_ROOT}/usr/bin")

vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_EXE_PATH ${BISON} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${BISON_EXE_PATH}")
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_EXE_PATH ${FLEX} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${FLEX_EXE_PATH}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static build of MikTeX is currently unavailable")
    set(LINK_EVERYTHING_STATICALLY ON)
    set(INSTALL_STATIC_LIBRARIES ON)
else()
    set(LINK_EVERYTHING_STATICALLY OFF)
    set(INSTALL_STATIC_LIBRARIES OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    GENERATOR "NMake Makefiles"
    OPTIONS
        # With
        -DWITH_UI_MFC=OFF
        -DWITH_COM=OFF
        -DWITH_MIKTEX_DOC=OFF
        -DWITH_UI_QT=OFF
        # # Static
        # -DLINK_EVERYTHING_STATICALLY=${LINK_EVERYTHING_STATICALLY}
        # -DINSTALL_STATIC_LIBRARIES=${INSTALL_STATIC_LIBRARIES}
        # # Use (essential for static build)
        # -DUSE_SYSTEM_CAIRO=ON
        # -DUSE_SYSTEM_FREETYPE2=ON
        # -DUSE_SYSTEM_JPEG=ON
        # -DUSE_SYSTEM_GD=ON
        # -DUSE_SYSTEM_GRAPHITE2=ON
        # -DUSE_SYSTEM_HUNSPELL=ON
        # -DUSE_SYSTEM_ZZIP=ON
        # # Use (dependencies brought by above packages)
        # -DUSE_SYSTEM_PNG=ON
        # -DUSE_SYSTEM_BZIP2=ON
        # -DUSE_SYSTEM_ZLIB=ON
        # -DUSE_SYSTEM_PIXMAN=ON
        # -DUSE_SYSTEM_FONTCONFIG=ON
        # -DUSE_SYSTEM_EXPAT=ON
        # -DUSE_SYSTEM_LZMA=ON
)

message(STATUS "Note: The building procedure will take hours")
find_program(NMAKE nmake REQUIRED)

################
# Debug build
################
message(STATUS "Building ${TARGET_TRIPLET}-dbg")

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)

vcpkg_execute_required_process(
    COMMAND ${NMAKE} clean install
    "INST_DIR=\"${INST_DIR_DBG}\"" INSTALLED_ROOT=${CURRENT_INSTALLED_DIR} "LIBS_ALL=${LIBS_ALL_DBG}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
vcpkg_copy_pdbs()

################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
vcpkg_execute_required_process(
    COMMAND ${NMAKE} clean install
    "INST_DIR=\"${INST_DIR_REL}\"" INSTALLED_ROOT=${CURRENT_INSTALLED_DIR} "LIBS_ALL=${LIBS_ALL_REL}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/texmf)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/miktex)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/texmf ${CURRENT_PACKAGES_DIR}/tools/texmf)

# if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
# else()
# endif()

# Copy over PDBs
vcpkg_copy_pdbs()

# Handle copyright
file(RENAME ${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/miktex/copyright)

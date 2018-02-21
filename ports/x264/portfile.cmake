# This portfile adds the Qt Cryptographic Arcitecture
# Changes to the original build:
#   No -qt5 suffix, which is recommended just for Linux
#   Output directories according to vcpkg
#   Updated certstore. See certstore.pem in the output dirs
#

#if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
#    set(VCPKG_LIBRARY_LINKAGE dynamic)
#endif()

include(vcpkg_common_functions)
set(X264_VERSION 152)

find_program(GIT git)
#vcpkg_find_acquire_program(PERL)
#get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
#set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")

# Set git variables to x264 version 2.2.0 commit 
set(GIT_URL "git://git.videolan.org/x264.git")
set(GIT_REF "e9a5903edf8ca59ef20e6f4894c196f135af735e") # Commit

# Prepare source dir
if(NOT EXISTS "${DOWNLOADS}/x264.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/x264.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/x264.git
        LOGNAME worktree
    )
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

# Apply the patch to install to the expected folders
#vcpkg_apply_patches(
#    SOURCE_PATH ${SOURCE_PATH}
#    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-fix-path-for-vcpkg.patch
#)

# Acquire tools
vcpkg_acquire_msys(MSYS_ROOT)

# Insert msys into the path between the compiler toolset and windows system32. This prevents masking of "link.exe" but DOES mask "find.exe".
string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
string(REPLACE ";$ENV{SystemRoot}\\System32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "${NEWPATH}")
set(ENV{PATH} "${NEWPATH}")
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "pacman -Sy --noconfirm --needed make automake1.15"
    WORKING_DIRECTORY "${MSYS_ROOT}"
    LOGNAME "pacman-${TARGET_TRIPLET}")

set(AUTOMAKE_DIR ${MSYS_ROOT}/usr/share/automake-1.15)
#file(COPY ${AUTOMAKE_DIR}/config.guess ${AUTOMAKE_DIR}/config.sub DESTINATION ${SOURCE_PATH}/source)

#set(CONFIGURE_OPTIONS "--host=i686-pc-mingw32 --disable-samples --disable-tests")
set(CONFIGURE_OPTIONS "--host=i686-pc-mingw32 --enable-strip --disable-lavf --disable-swscale --disable-asm")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-shared")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static")
endif()

#set(CONFIGURE_OPTIONS_RELASE "--disable-debug --enable-release --prefix=${CURRENT_PACKAGES_DIR}")
#set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --disable-release --prefix=${CURRENT_PACKAGES_DIR}/debug")
set(CONFIGURE_OPTIONS_RELASE "--prefix=${CURRENT_PACKAGES_DIR}")
set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --prefix=${CURRENT_PACKAGES_DIR}/debug")

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(X264_RUNTIME "-MT")
else()
    set(X264_RUNTIME "-MD")
endif()

# Configure release
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
set(ENV{CFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
set(ENV{CXXFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
set(ENV{LDFLAGS} "-DEBUG -INCREMENTAL:NO -OPT:REF -OPT:ICF")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELASE}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "configure-${TARGET_TRIPLET}-rel")
message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

# Configure debug
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
set(ENV{CFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
set(ENV{CXXFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
set(ENV{LDFLAGS} "-DEBUG")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME "configure-${TARGET_TRIPLET}-dbg")
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")

unset(ENV{CFLAGS})
unset(ENV{CXXFLAGS})
unset(ENV{LDFLAGS})

# Build release
message(STATUS "Package ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make && make install"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "build-${TARGET_TRIPLET}-rel")
message(STATUS "Package ${TARGET_TRIPLET}-rel done")

# Build debug
message(STATUS "Package ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make && make install"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME "build-${TARGET_TRIPLET}-dbg")
message(STATUS "Package ${TARGET_TRIPLET}-dbg done")

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/share
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/lib/x264
    ${CURRENT_PACKAGES_DIR}/debug/lib/x264)

#file(GLOB TEST_LIBS
#    ${CURRENT_PACKAGES_DIR}/lib/*test*
#    ${CURRENT_PACKAGES_DIR}/debug/lib/*test*)
#file(REMOVE ${TEST_LIBS})

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # copy x264 dlls from lib to bin
    file(GLOB RELEASE_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libx264-${X264_VERSION}.dll)
    file(GLOB DEBUG_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libx264-${X264_VERSION}.dll)
    file(COPY ${RELEASE_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    # rename static libraries to match import libs
    # see https://gitlab.kitware.com/cmake/cmake/issues/16617
    foreach(MODULE dt in io tu uc)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/x264${MODULE}.lib ${CURRENT_PACKAGES_DIR}/lib/x264${MODULE}.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/x264${MODULE}.lib ${CURRENT_PACKAGES_DIR}/debug/lib/x264${MODULE}.lib)
    endforeach()

    # force U_STATIC_IMPLEMENTATION macro
    foreach(HEADER x264.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/unicode/${HEADER} HEADER_CONTENTS)
        string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/unicode/${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

# remove any remaining dlls in /lib
file(GLOB DUMMY_DLLS ${CURRENT_PACKAGES_DIR}/lib/*.dll ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
if(DUMMY_DLLS)
    file(REMOVE ${DUMMY_DLLS})
endif()

# Generates warnings about missing pdbs for icudt.dll
# This is expected because ICU database contains no executable code
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/x264)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/x264/COPYING ${CURRENT_PACKAGES_DIR}/share/x264/copyright)

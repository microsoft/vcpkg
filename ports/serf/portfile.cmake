if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

set(VERSION 1.3.9)
set(SCONS_VERSION 4.1.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/serf/serf-${VERSION}.tar.bz2"
    FILENAME "serf-${VERSION}.tar.bz2"
    SHA512 9f5418d991840a08d293d1ecba70cd9534a207696d002f22dbe62354e7b005955112a0d144a76c89c7f7ad3b4c882e54974441fafa0c09c4aa25c49c021ca75d
)

vcpkg_download_distfile(SCONS_ARCHIVE
    URLS "https://prdownloads.sourceforge.net/scons/scons-local-${SCONS_VERSION}.tar.gz"
    FILENAME "scons-local-${SCONS_VERSION}.tar.gz"
    SHA512 e52da08dbd4e451ec76f0b45547880a3e2fbd19b07a16b1cc9c0525f09211162ef59ff1ff49fd76d323e1e2a612ebbafb646710339569677e14193d49c8ebaeb
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        SConstruct-python3.patch
)

# Obtain the SCons buildmanager, for setting up the build
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SCONS_PATH
    ARCHIVE ${SCONS_ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

vcpkg_find_acquire_program(PYTHON3)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  set(SCONS_ARCH "TARGET_ARCH=x86_64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
  set(SCONS_ARCH "TARGET_ARCH=x86")
else()
  set(SCONS_ARCH "")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(APR_MODE "")
else()
  set(APR_MODE "APR_STATIC=yes")
endif()

vcpkg_execute_build_process(
    COMMAND ${PYTHON3} ${SCONS_PATH}/scons.py PREFIX=${CURRENT_PACKAGES_DIR} LIBDIR=${CURRENT_PACKAGES_DIR}/lib OPENSSL=${CURRENT_INSTALLED_DIR} ZLIB=${CURRENT_INSTALLED_DIR} APR=${CURRENT_INSTALLED_DIR} APU=${CURRENT_INSTALLED_DIR} SOURCE_LAYOUT=no ${APR_MODE} ${SCONS_ARCH} install-lib install-inc
    WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_execute_build_process(
    COMMAND ${PYTHON3} ${SCONS_PATH}/scons.py PREFIX=${CURRENT_PACKAGES_DIR}/debug LIBDIR=${CURRENT_PACKAGES_DIR}/debug/lib OPENSSL=${CURRENT_INSTALLED_DIR} ZLIB=${CURRENT_INSTALLED_DIR} APR=${CURRENT_INSTALLED_DIR} APU=${CURRENT_INSTALLED_DIR} SOURCE_LAYOUT=no ${APR_MODE} ${SCONS_ARCH} DEBUG=yes install-lib install-inc
    WORKING_DIRECTORY ${SOURCE_PATH}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/serf/copyright" COPYONLY)


if (VCPKG_TARGET_IS_WINDOWS)
    # Both dynamic and static are built, so keep only the one needed
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/serf-1.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/serf-1.lib)

        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libserf-1.dll ${CURRENT_PACKAGES_DIR}/bin/libserf-1.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libserf-1.pdb ${CURRENT_PACKAGES_DIR}/bin/libserf-1.pdb)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libserf-1.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/libserf-1.pdb)
    else()
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libserf-1.lib
                    ${CURRENT_PACKAGES_DIR}/lib/libserf-1.exp
                    ${CURRENT_PACKAGES_DIR}/lib/libserf-1.dll
                    ${CURRENT_PACKAGES_DIR}/lib/libserf-1.pdb
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.exp
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.dll
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.pdb)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
else()
    # TODO: Build similar as on Windows
endif()
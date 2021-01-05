# Patches are from:
# - https://github.com/python-cmake-buildsystem/python-cmake-buildsystem/tree/master/patches/2.7.13/Windows-MSVC/1900
# - https://github.com/Microsoft/vcpkg/tree/master/ports/python3

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(PYTHON_VERSION_MAJOR  2)
set(PYTHON_VERSION_MINOR  7)
set(PYTHON_VERSION_PATCH  15)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})

set(_PYTHON_PATCHES "")
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND _PYTHON_PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/004-static-library-msvc.patch
        ${CMAKE_CURRENT_LIST_DIR}/006-static-fix-headers.patch
    )
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static)
    list(APPEND _PYTHON_PATCHES ${CMAKE_CURRENT_LIST_DIR}/005-static-crt-msvc.patch)
endif()


vcpkg_download_distfile(ARCHIVE
    URLS https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
    FILENAME Python-${PYTHON_VERSION}.tar.xz
    SHA512 27ea43eb45fc68f3d2469d5f07636e10801dee11635a430ec8ec922ed790bb426b072da94df885e4dfa1ea8b7a24f2f56dd92f9b0f51e162330f161216bd6de6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/001-build-msvc.patch
        ${CMAKE_CURRENT_LIST_DIR}/002-build-msvc.patch
        ${CMAKE_CURRENT_LIST_DIR}/003-build-msvc.patch
        ${_PYTHON_PATCHES}
        ${CMAKE_CURRENT_LIST_DIR}/007-fix-build-path.patch
)

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(BUILD_ARCH "Win32")
    set(OUT_DIR "win32")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(BUILD_ARCH "x64")
    set(OUT_DIR "amd64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH PCBuild/pythoncore.vcxproj
    PLATFORM ${BUILD_ARCH}
)

file(REMOVE ${CURRENT_PACKAGES_DIR}/tools ${CURRENT_PACKAGES_DIR}/debug/tools)

# Install headers manually
file(GLOB HEADERS ${SOURCE_PATH}/Include/*.h)
file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})

if ("tools" IN_LIST FEATURES)
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH PCBuild/python.vcxproj
        PLATFORM ${BUILD_ARCH}
    )
    
    vcpkg_copy_tools(TOOL_NAMES python w9xpopen SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools/python2 AUTO_CLEAN)
    
    file(COPY ${SOURCE_PATH}/Lib DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}" RENAME copyright)

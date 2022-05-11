# Patches are from:
# - https://github.com/python-cmake-buildsystem/python-cmake-buildsystem/tree/master/patches/2.7.13/Windows-MSVC/1900
# - https://github.com/Microsoft/vcpkg/tree/master/ports/python3

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(PYTHON_VERSION_MAJOR  2)
set(PYTHON_VERSION_MINOR  7)
set(PYTHON_VERSION_PATCH  18)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})

set(_PYTHON_PATCHES "")
if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND _PYTHON_PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/001-build-msvc.patch
        ${CMAKE_CURRENT_LIST_DIR}/002-build-msvc.patch
        ${CMAKE_CURRENT_LIST_DIR}/003-build-msvc.patch
    )
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND _PYTHON_PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/004-static-library-msvc.patch
        ${CMAKE_CURRENT_LIST_DIR}/006-static-fix-headers.patch
    )
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static)
    list(APPEND _PYTHON_PATCHES ${CMAKE_CURRENT_LIST_DIR}/005-static-crt-msvc.patch)
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND _PYTHON_PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/007-fix-build-path.patch
    )
else()
    list(APPEND _PYTHON_PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/008-bz2d.patch
    )
endif()


vcpkg_download_distfile(ARCHIVE
    URLS https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
    FILENAME Python-${PYTHON_VERSION}.tar.xz
    SHA512 a7bb62b51f48ff0b6df0b18f5b0312a523e3110f49c3237936bfe56ed0e26838c0274ff5401bda6fc21bf24337477ccac49e8026c5d651e4b4cafb5eb5086f6c
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES ${_PYTHON_PATCHES}
)

vcpkg_replace_string("${SOURCE_PATH}/Makefile.pre.in" "$(INSTALL) -d -m $(DIRMODE)" "$(MKDIR_P)")

if (VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(BUILD_ARCH "Win32")
        set(OUT_DIR "win32")
    elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(BUILD_ARCH "x64")
        set(OUT_DIR "amd64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/PCBuild/pythoncore.vcxproj
        PLATFORM ${BUILD_ARCH}
    )

    vcpkg_copy_pdbs()
    
    file(GLOB HEADERS ${SOURCE_PATH}/Include/*.h)
    file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})
    
    file(COPY ${SOURCE_PATH}/Lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
    
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

if (NOT VCPKG_TARGET_IS_WINDOWS)
    foreach(lib_suffix IN ITEMS "" "/debug")
        set(python_config_file "${CURRENT_PACKAGES_DIR}${lib_suffix}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/_sysconfigdata.py")
        if(NOT EXISTS "${python_config_file}")
            continue()
        endif()
        
        file(READ "${python_config_file}" contents)

        string(PREPEND contents "import os\n_base = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))\n")
        # make contents a list of lines
        string(REPLACE ";" "\\;" old_contents "${contents}")
        string(REGEX REPLACE "\r?\n" ";" old_contents "${contents}")

        set(new_contents "")
        foreach(line IN LISTS old_contents)
            if(line MATCHES "\"")
                string(REGEX REPLACE
                    "${CURRENT_PACKAGES_DIR}|${CURRENT_INSTALLED_DIR}"
                    "\" + _base + \""
                    line
                    "${line}"
                )
                string(REGEX REPLACE
                    "\"[^\"]*${CURRENT_BUILDTREES_DIR}[^\"]*\""
                    "''"
                    line
                    "${line}"
                )
            else()
                string(REGEX REPLACE
                    "${CURRENT_PACKAGES_DIR}|${CURRENT_INSTALLED_DIR}"
                    "' + _base + '"
                    line
                    "${line}"
                )
                string(REGEX REPLACE
                    "'[^']*${CURRENT_BUILDTREES_DIR}[^']*'"
                    "''"
                    line
                    "${line}"
                )
            endif()
            list(APPEND new_contents "${line}")
        endforeach()

        list(JOIN new_contents "\n" contents)
        file(WRITE "${python_config_file}" "${contents}")
    endforeach()
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/copyright)

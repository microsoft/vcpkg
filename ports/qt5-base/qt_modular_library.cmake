set(_qt5base_port_dir "${CMAKE_CURRENT_LIST_DIR}")

function(qt_modular_fix_cmake)
#Find Python and add it to the path
    
    #Fix the cmake files if they exist
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake)
        vcpkg_execute_required_process(
            COMMAND ${PYTHON2} ${_qt5base_port_dir}/fixcmake.py ${PORT}
            WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/cmake
            LOGNAME fix-cmake
        )
    endif()
    
    #Install cmake files
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
    endif()
    #Remove extra cmake files
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
    endif()
endfunction()

function(qt_modular_fetch_library NAME HASH TARGET_SOURCE_PATH)
    string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
    if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
        message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
            "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
        )
    endif()
    
    if(NOT DEFINED QT_MAJOR_MINOR_VER)
        set(MAJOR_MINOR 5.12)
    else()
        message(STATUS "Qt5 hash checks disabled!")
        set(MAJOR_MINOR ${QT_MAJOR_MINOR_VER})
        
        set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    endif()

    if(NOT DEFINED QT_PATCH_VER)
        set(PATCH 4)
    else()
        set(PATCH ${QT_PATCH_VER})
    endif()
    
    set(FULL_VERSION ${MAJOR_MINOR}.${PATCH})
    set(ARCHIVE_NAME "${NAME}-everywhere-src-${FULL_VERSION}.tar.xz")

    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "http://download.qt.io/official_releases/qt/${MAJOR_MINOR}/${FULL_VERSION}/submodules/${ARCHIVE_NAME}"
        FILENAME ${ARCHIVE_NAME}
        SHA512 ${HASH}
    )
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${ARCHIVE_FILE}"
        REF ${FULL_VERSION}
        PATCHES ${_csc_PATCHES}
    )

    set(${TARGET_SOURCE_PATH} ${SOURCE_PATH} PARENT_SCOPE)
endfunction()

function(qt_modular_build_library SOURCE_PATH)
    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV{_CL_} "/utf-8")

    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
    vcpkg_add_to_path("${PYTHON2_EXE_PATH}")
    
    vcpkg_configure_qmake(SOURCE_PATH ${SOURCE_PATH})

    vcpkg_build_qmake(SKIP_MAKEFILES)

    #Fix the installation location
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
    
    if(WIN32)
        string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 2 -1 INSTALLED_DIR_WITHOUT_DRIVE)
        string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 2 -1 PACKAGES_DIR_WITHOUT_DRIVE)
    else()
        set(INSTALLED_DIR_WITHOUT_DRIVE ${NATIVE_INSTALLED_DIR})
        set(PACKAGES_DIR_WITHOUT_DRIVE ${NATIVE_PACKAGES_DIR})
    endif()

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
    
    file(GLOB_RECURSE MAKEFILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*Makefile*" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*Makefile*")

    foreach(MAKEFILE ${MAKEFILES})
        file(READ "${MAKEFILE}" _contents)
        #Set the correct install directory to packages
        string(REPLACE "(INSTALL_ROOT)${INSTALLED_DIR_WITHOUT_DRIVE}" "(INSTALL_ROOT)${PACKAGES_DIR_WITHOUT_DRIVE}" _contents "${_contents}")
        file(WRITE "${MAKEFILE}" "${_contents}")
    endforeach()
    
    #Install the module files
    vcpkg_build_qmake(TARGETS install SKIP_MAKEFILES BUILD_LOGNAME install)
    
    qt_modular_fix_cmake()

    unset(BUILDTYPES)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(_buildname "DEBUG")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "dbg")
        set(_path_suffix_${_buildname} "/debug")        
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_buildname "RELEASE")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "rel")
        set(_path_suffix_${_buildname} "")        
    endif()
    unset(_buildname)

    foreach(_buildname ${BUILDTYPES})
        set(CURRENT_BUILD_PACKAGE_DIR "${CURRENT_PACKAGES_DIR}${_path_suffix_${_buildname}}")
        #Fix PRL files 
        file(GLOB_RECURSE PRL_FILES "${CURRENT_BUILD_PACKAGE_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5${_path_suffix_${_buildname}}/lib/*.prl" 
                                    "${CURRENT_PACKAGES_DIR}/tools/qt5${_path_suffix_${_buildname}}/mkspecs/*.pri")
        file(TO_CMAKE_PATH "${CURRENT_BUILD_PACKAGE_DIR}/lib" CMAKE_LIB_PATH)
        file(TO_CMAKE_PATH "${CURRENT_BUILD_PACKAGE_DIR}/include" CMAKE_INCLUDE_PATH)
        foreach(PRL_FILE IN LISTS PRL_FILES)
            file(READ "${PRL_FILE}" _contents)
            string(REPLACE "${CMAKE_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
            string(REPLACE "${CMAKE_INCLUDE_PATH}" "\$\$[QT_INSTALL_HEADERS]" _contents "${_contents}")
        file(WRITE "${PRL_FILE}" "${_contents}")
        endforeach()
        
        # This makes it impossible to use the build tools in any meaningful way. qt5 assumes they are all in one folder!
        # So does the Qt VS Plugin which even assumes all of the in a bin folder  
        #Move tools to the correct directory
        #if(EXISTS ${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5)
        #    file(RENAME ${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5 ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        #endif()
        
        # Move executables in bin to tools
        # This is ok since those are not build tools.
        file(GLOB PACKAGE_EXE ${CURRENT_BUILD_PACKAGE_DIR}/bin/*.exe)
        if(PACKAGE_EXE)
            file(INSTALL ${PACKAGE_EXE} DESTINATION ${CURRENT_BUILD_PACKAGE_DIR}/tools/${PORT})
            file(REMOVE ${PACKAGE_EXE})
            foreach(_exe ${PACKAGE_EXE})
                string(REPLACE ".exe" ".pdb" _prb_file ${_exe})
                if(EXISTS ${_prb_file})
                    file(INSTALL ${_prb_file} DESTINATION ${CURRENT_BUILD_PACKAGE_DIR}/tools/${PORT})
                    file(REMOVE ${_prb_file})
                endif()
            endforeach()
        endif()
        
        #cleanup empty folders
        file(GLOB PACKAGE_LIBS ${CURRENT_BUILD_PACKAGE_DIR}/lib/*)
        if(NOT PACKAGE_LIBS)
            file(REMOVE_RECURSE ${CURRENT_BUILD_PACKAGE_DIR}/lib)
        endif()
        
        file(GLOB PACKAGE_BINS ${CURRENT_BUILD_PACKAGE_DIR}/bin/*)
        if(NOT PACKAGE_BINS)
            file(REMOVE_RECURSE ${CURRENT_BUILD_PACKAGE_DIR}/bin)
        endif()
        
        #vcpkg_copy_tool_dependencies(${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5/bin)
        vcpkg_copy_tool_dependencies(${CURRENT_BUILD_PACKAGE_DIR}/tools/${PORT})
    endforeach()
endfunction()

function(qt_modular_install_license SOURCE_PATH)
    #Find the relevant license file and install it
    if(EXISTS "${SOURCE_PATH}/LICENSE.LGPLv3")
        set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.LGPLv3")
    elseif(EXISTS "${SOURCE_PATH}/LICENSE.LGPL3")
        set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.LGPL3")
    elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPLv3")
        set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPLv3")
    elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPL3")
        set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPL3")
    elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPL3-EXCEPT")
        set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPL3-EXCEPT")
    endif()
    file(INSTALL ${LICENSE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endfunction()

function(qt_modular_library NAME HASH)
    cmake_parse_arguments(_csc "" "" "PATCHES" ${ARGN}) 
  
    qt_modular_fetch_library(${NAME} ${HASH} TARGET_SOURCE_PATH)
      
    qt_modular_build_library(${TARGET_SOURCE_PATH})   

    qt_modular_install_license(${TARGET_SOURCE_PATH})
endfunction()
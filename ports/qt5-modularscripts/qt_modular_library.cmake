set(_qt5base_port_dir "${CMAKE_CURRENT_LIST_DIR}")

function(qt_modular_library NAME HASH)
    string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
    if(BUILDTREES_PATH_LENGTH GREATER 45)
        message(WARNING "Qt5's buildsystem uses very long paths and may fail on your system.\n"
            "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
        )
    endif()

    set(MAJOR_MINOR 5.12)
    set(FULL_VERSION ${MAJOR_MINOR}.1)
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
    )

    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV{_CL_} "/utf-8")

    #Store build paths
    set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

    #Find Python and add it to the path
    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
    set(ENV{PATH} "${PYTHON2_EXE_PATH};$ENV{PATH}")

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)

    if(WIN32)
        string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 2 -1 INSTALLED_DIR_WITHOUT_DRIVE)
        string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 2 -1 PACKAGES_DIR_WITHOUT_DRIVE)
    else()
        set(INSTALLED_DIR_WITHOUT_DRIVE ${NATIVE_INSTALLED_DIR})
        set(PACKAGES_DIR_WITHOUT_DRIVE ${NATIVE_PACKAGES_DIR})
    endif()

    #Configure debug+release
    vcpkg_configure_qmake(SOURCE_PATH ${SOURCE_PATH})

    vcpkg_build_qmake()

    #Fix the cmake files if they exist
    if(EXISTS ${RELEASE_DIR}/lib/cmake)
        vcpkg_execute_required_process(
            COMMAND ${PYTHON2} ${_qt5base_port_dir}/fixcmake.py ${PORT}
            WORKING_DIRECTORY ${RELEASE_DIR}/lib/cmake
            LOGNAME fix-cmake
        )
    endif()

    file(GLOB_RECURSE MAKEFILES ${DEBUG_DIR}/*Makefile* ${RELEASE_DIR}/*Makefile*)

    foreach(MAKEFILE ${MAKEFILES})
        file(READ "${MAKEFILE}" _contents)
        #Set the correct install directory to packages
        string(REPLACE "(INSTALL_ROOT)${INSTALLED_DIR_WITHOUT_DRIVE}" "(INSTALL_ROOT)${PACKAGES_DIR_WITHOUT_DRIVE}" _contents "${_contents}")
        file(WRITE "${MAKEFILE}" "${_contents}")
    endforeach()

    #Install the module files
    vcpkg_build_qmake(TARGETS install SKIP_MAKEFILES BUILD_LOGNAME install)

    #Remove extra cmake files
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
    endif()
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
    endif()

    file(GLOB_RECURSE PRL_FILES "${CURRENT_PACKAGES_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/debug/lib/*.prl")
    file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/lib" CMAKE_RELEASE_LIB_PATH)
    file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib" CMAKE_DEBUG_LIB_PATH)
    foreach(PRL_FILE IN LISTS PRL_FILES)
        file(READ "${PRL_FILE}" _contents)
        string(REPLACE "${CMAKE_RELEASE_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
        string(REPLACE "${CMAKE_DEBUG_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
        file(WRITE "${PRL_FILE}" "${_contents}")
    endforeach()

    file(GLOB RELEASE_LIBS "${CURRENT_PACKAGES_DIR}/lib/*")
    if(NOT RELEASE_LIBS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
    endif()
    file(GLOB DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*")
    if(NOT DEBUG_FILES)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif()

    #Move release and debug dlls to the correct directory
    if(EXISTS ${CURRENT_PACKAGES_DIR}/tools/qt5)
        file(RENAME ${CURRENT_PACKAGES_DIR}/tools/qt5 ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/tools/qt5 ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT})
    endif()

    file(GLOB RELEASE_DLLS ${CURRENT_PACKAGES_DIR}/tools/${PORT}/*.dll)
    file(GLOB DEBUG_DLLS ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/*.dll)
    if (RELEASE_DLLS)
        file(INSTALL ${RELEASE_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(REMOVE ${RELEASE_DLLS})
        #Check if there are any binaries left over; if not - delete the directory
        file(GLOB RELEASE_BINS ${CURRENT_PACKAGES_DIR}/tools/${PORT}/*)
        if(NOT RELEASE_BINS)
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools)
        endif()
    endif()
    if(DEBUG_DLLS)
        file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/tools)
    endif()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/qt5/debug/include)

    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

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

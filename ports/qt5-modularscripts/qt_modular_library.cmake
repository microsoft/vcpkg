set(_qt5base_port_dir "${CMAKE_CURRENT_LIST_DIR}")

function(qt_modular_library NAME HASH)
    string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
    if(BUILDTREES_PATH_LENGTH GREATER 45)
        message(WARNING "Qt5's buildsystem uses very long paths and may fail on your system.\n"
            "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
        )
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        message(FATAL_ERROR "Qt5 doesn't currently support static builds. Please use a dynamic triplet instead.")
    endif()

    set(SRCDIR_NAME "${NAME}-5.9.2")
    set(ARCHIVE_NAME "${NAME}-opensource-src-5.9.2")
    set(ARCHIVE_EXTENSION ".tar.xz")

    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${SRCDIR_NAME})
    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "http://download.qt.io/official_releases/qt/5.9/5.9.2/submodules/${ARCHIVE_NAME}${ARCHIVE_EXTENSION}"
        FILENAME ${SRCDIR_NAME}${ARCHIVE_EXTENSION}
        SHA512 ${HASH}
    )
    vcpkg_extract_source_archive(${ARCHIVE_FILE})
    if (EXISTS ${CURRENT_BUILDTREES_DIR}/src/${ARCHIVE_NAME})
        file(RENAME ${CURRENT_BUILDTREES_DIR}/src/${ARCHIVE_NAME} ${CURRENT_BUILDTREES_DIR}/src/${SRCDIR_NAME})
    endif()

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

    string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 2 -1 INSTALLED_DIR_WITHOUT_DRIVE)
    string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 2 -1 PACKAGES_DIR_WITHOUT_DRIVE)
    
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

    #Set the correct install directory to packages
    foreach(MAKEFILE ${MAKEFILES})
        vcpkg_replace_string(${MAKEFILE} "(INSTALL_ROOT)${INSTALLED_DIR_WITHOUT_DRIVE}" "(INSTALL_ROOT)${PACKAGES_DIR_WITHOUT_DRIVE}")
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
    endif()
    file(INSTALL ${LICENSE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

endfunction()
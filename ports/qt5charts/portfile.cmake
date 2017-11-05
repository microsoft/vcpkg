include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37)
    message(WARNING "Qt5's buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Qt5 doesn't currently support static builds. Please use a dynamic triplet instead.")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

set(SRCDIR_NAME "qtcharts-5.9.2")
set(ARCHIVE_NAME "qtcharts-opensource-src-5.9.2")
set(ARCHIVE_EXTENSION ".tar.xz")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${SRCDIR_NAME})
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://download.qt.io/official_releases/qt/5.9/5.9.2/submodules/${ARCHIVE_NAME}${ARCHIVE_EXTENSION}"
    FILENAME ${SRCDIR_NAME}${ARCHIVE_EXTENSION}
    SHA512 297547b565dd71b05237bb05ecc1abf1a774a4909668417e78bd65e805c1e47a456a5a06898fe06d4c4614118e4129e19893d4c77598667a9354ab969307a293
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
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
set(ENV{PATH} "${PYTHON3_EXE_PATH};$ENV{PATH}")
set(_path "$ENV{PATH}")

#Configure debug
vcpkg_configure_qmake_debug(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${SRCDIR_NAME}
)

#First generate the makefiles so we can modify them
vcpkg_build_qmake_debug(TARGETS sub-src-qmake_all)

#Store debug makefiles path
file(GLOB_RECURSE DEBUG_MAKEFILES ${DEBUG_DIR}/*Makefile*)

#Fix path to Qt5QmlDevTools
foreach(DEBUG_MAKEFILE ${DEBUG_MAKEFILES})
    vcpkg_replace_string(${DEBUG_MAKEFILE} "vcpkg\\installed\\${TARGET_TRIPLET}\\lib\\Qt5QmlDevToolsd.lib" "vcpkg\\installed\\${TARGET_TRIPLET}\\debug\\lib\\Qt5QmlDevToolsd.lib")
endforeach()

#Build debug
vcpkg_build_qmake_debug()

#Configure release
vcpkg_configure_qmake_release(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${SRCDIR_NAME}
)

#First generate the makefiles so we can modify them
vcpkg_build_qmake_release(TARGETS sub-src-qmake_all)

#Store release makefile path
file(GLOB_RECURSE RELEASE_MAKEFILES ${RELEASE_DIR}/*Makefile*)

#Build release
vcpkg_build_qmake_release()

#Fix the cmake files if they exist
if(EXISTS ${RELEASE_DIR}/lib/cmake)
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
        WORKING_DIRECTORY ${RELEASE_DIR}/lib/cmake
        LOGNAME fix-cmake
    )
endif()

#Set the correct install directory to packages
foreach(RELEASE_MAKEFILE ${RELEASE_MAKEFILES})
        vcpkg_replace_string(${RELEASE_MAKEFILE} "(INSTALL_ROOT)\\vcpkg\\installed\\${TARGET_TRIPLET}" "(INSTALL_ROOT)\\vcpkg\\packages\\${PORT}_${TARGET_TRIPLET}")
endforeach()
foreach(DEBUG_MAKEFILE ${DEBUG_MAKEFILES})
    vcpkg_replace_string(${DEBUG_MAKEFILE} "(INSTALL_ROOT)\\vcpkg\\installed\\${TARGET_TRIPLET}" "(INSTALL_ROOT)\\vcpkg\\packages\\${PORT}_${TARGET_TRIPLET}")
endforeach()

#Install the module files
vcpkg_build_qmake_debug(TARGETS install)
vcpkg_build_qmake_release(TARGETS install)

#Reset the path to the baseline
set(ENV{PATH} "${_path}")

#Remove extra cmake files
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
    #Check if there are any libs left over; if not - delete the directory
    file(GLOB RELEASE_LIBS ${CURRENT_PACKAGES_DIR}/lib/*)
    if(NOT RELEASE_LIBS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
    endif()
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
    #Check if there are any libs left over; if not - delete the directory
    file(GLOB DEBUG_LIBS ${CURRENT_PACKAGES_DIR}/lib/*)
    if(NOT DEBUG_LIBS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif()
endif()

#Move release and debug dlls to the correct directory
file(GLOB RELEASE_DLLS ${CURRENT_PACKAGES_DIR}/tools/qt5/*.dll)
file(GLOB DEBUG_DLLS ${CURRENT_PACKAGES_DIR}/debug/tools/qt5/*.dll)
if (RELEASE_DLLS)
    file(INSTALL ${RELEASE_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE ${RELEASE_DLLS})
    #Check if there are any binaries left over; if not - delete the directory
    file(GLOB RELEASE_BINS ${CURRENT_PACKAGES_DIR}/tools/qt5/*)
    if(NOT RELEASE_BINS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools)
    endif()
endif()
if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${DEBUG_DLLS})
    #Check if there are any binaries left over; if not - delete the directory
    file(GLOB DEBUG_BINS ${CURRENT_PACKAGES_DIR}/debug/tools/qt5/*)
    if(NOT DEBUG_BINS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/tools)
    endif()
endif()

#If there are no include files in the module - create an empty one to stop vcpkg from complaining
if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include)
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/.empty_${PORT} "")
endif()

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
file(INSTALL ${LICENSE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/ RENAME copyright)
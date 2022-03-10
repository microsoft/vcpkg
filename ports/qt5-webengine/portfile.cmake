vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtrees_path_length)
if(buildtrees_path_length GREATER 35 AND CMAKE_HOST_WIN32)
    vcpkg_buildpath_length_warning(35)
    message(FATAL_ERROR "terminating due to source length.")
endif()
#set(VCPKG_BUILD_TYPE release) #You probably want to set this to reduce build type and space requirements
message(STATUS "${PORT} requires a lot of free disk space (>100GB), ram (>8 GB) and time (>2h per configuration) to be successfully build.\n\
-- As such ${PORT} is currently experimental.\n\
-- If ${PORT} fails post build validation please open up an issue. \n\
-- If it fails due to post validation the successfully installed files can be found in ${CURRENT_PACKAGES_DIR} \n\
-- and just need to be copied into ${CURRENT_INSTALLED_DIR}")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "If ${PORT} directly fails ${PORT} might require additional prerequisites on Linux and OSX. Please check the configure logs.\n")
endif()
include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(PYTHON2)
vcpkg_find_acquire_program(NINJA)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY )
get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY )
get_filename_component(NINJA_DIR "${NINJA}" DIRECTORY )

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()

vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")
vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")
vcpkg_add_to_path(PREPEND "${GPERF_DIR}")
vcpkg_add_to_path(PREPEND "${NINJA_DIR}")

set(PATCHES common.pri.patch 
            gl.patch
            build_1.patch
            build_2.patch)

set(OPTIONS)
if("proprietary-codecs" IN_LIST FEATURES)
    list(APPEND OPTIONS "-webengine-proprietary-codecs")
endif()
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS "-webengine-system-libwebp" "-webengine-system-ffmpeg" "-webengine-system-icu")
endif()

qt_submodule_installation(PATCHES ${PATCHES} BUILD_OPTIONS ${OPTIONS})

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtrees_path_length)
if(buildtrees_path_length GREATER 35 AND CMAKE_HOST_WIN32)
    vcpkg_buildpath_length_warning(35)
    message(WARNING "The ${PORT} source was will be extracted to ${CURRENT_BUILDTREES_DIR} , which has more then 35 characters in length.")
    message(FATAL_ERROR "terminating due to ${CURRENT_BUILDTREES_DIR} being too long.")
endif()
#set(VCPKG_BUILD_TYPE release) #You probably want to set this to reduce build type and space requirements
message(STATUS "${PORT} requires a lot of free disk space (>100GB), ram (>8 GB) and time (>2h per configuration) to be successfully build.\n\
-- As such ${PORT} is currently experimental.\n\
-- If ${PORT} fails post build validation please try manually reducing VCPKG_MAX_CONCURRENCY and open up an issue if it still cannot build. \n\
-- If it fails due to post validation the successfully installed files can be found in ${CURRENT_PACKAGES_DIR} \n\
-- and just need to be copied into ${CURRENT_INSTALLED_DIR}")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "If ${PORT} directly fails ${PORT} might require additional prerequisites on Linux and OSX. Please check the configure logs.\n")
endif()
include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(PYTHON2)
vcpkg_find_acquire_program(NINJA)
set(NODEJS "${CURRENT_HOST_INSTALLED_DIR}/tools/node/node${VCPKG_HOST_EXECUTABLE_SUFFIX}")
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY )
get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY )
get_filename_component(NINJA_DIR "${NINJA}" DIRECTORY )
get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )

if(CMAKE_HOST_WIN32) # WIN32 HOST probably has win_flex and win_bison!
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
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")

vcpkg_execute_in_download_mode(
    COMMAND "${NINJA}" --version
    OUTPUT_VARIABLE ninja_version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
)
if(ninja_version VERSION_GREATER_EQUAL "1.12.1")
    message(WARNING
        "Found ninja version ${ninja_version} which may fail to build ${PORT}."
        "You can supply a different filepath using per-port customization of CMake variable NINJA."
    )
endif()

set(PATCHES common.pri.patch
            gl.patch
            build_1.patch
            0001-Support-ICU-74-in-LazyTextBreakIterator.patch
            workaround-protobuf-issue.patch
            0001-Fix-jumbo-build-error-due-to-ResolveColor-redefiniti.patch
	    fix-spellcheck-buildflags.patch
            )

set(OPTIONS)
if("proprietary-codecs" IN_LIST FEATURES)
    list(APPEND OPTIONS "-webengine-proprietary-codecs")
endif()
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS "-system-webengine-webp" "-system-webengine-icu")
    vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
    vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_host_path_list(PREPEND ENV{C_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_host_path_list(PREPEND ENV{CPLUS_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
endif()

qt_submodule_installation(PATCHES ${PATCHES} BUILD_OPTIONS ${OPTIONS})

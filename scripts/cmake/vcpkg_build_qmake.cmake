#.rst:
# .. command:: vcpkg_build_qmake
#
#  Build a qmake-based project, previously configured using vcpkg_configure_qmake.
#
#  ::
#  vcpkg_build_qmake()
#

function(vcpkg_build_qmake)
    cmake_parse_arguments(_csc "SKIP_MAKEFILES" "BUILD_LOGNAME" "TARGETS;RELEASE_TARGETS;DEBUG_TARGETS" ${ARGN})

    if(CMAKE_HOST_WIN32)
        vcpkg_find_acquire_program(JOM)
        set(INVOKE "${JOM}")
    else()
        find_program(MAKE make)
        set(INVOKE "${MAKE}")
    endif()

    # Make sure that the linker finds the libraries used 
    set(ENV_PATH_BACKUP "$ENV{PATH}")
    
    set(DEBUG_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    set(RELEASE_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)

    list(APPEND _csc_RELEASE_TARGETS ${_csc_TARGETS})
    list(APPEND _csc_DEBUG_TARGETS ${_csc_TARGETS})

    if(NOT _csc_BUILD_LOGNAME)
        set(_csc_BUILD_LOGNAME build)
    endif()

    function(run_jom TARGETS LOG_PREFIX LOG_SUFFIX)
        message(STATUS "Package ${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} ${TARGETS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${LOG_SUFFIX}
            LOGNAME package-${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}
        )
    endfunction()

    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV_CL_BACKUP "$ENV{_CL_}")
    set(ENV{_CL_} "/utf-8")

    #First generate the makefiles so we can modify them
    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/debug/lib;${CURRENT_INSTALLED_DIR}/debug/bin;${CURRENT_INSTALLED_DIR}/tools/qt5;${ENV_PATH_BACKUP}")
    if(NOT _csc_SKIP_MAKEFILES)
        run_jom(qmake_all makefiles dbg)

        #Store debug makefiles path
        file(GLOB_RECURSE DEBUG_MAKEFILES ${DEBUG_DIR}/*Makefile*)

        foreach(DEBUG_MAKEFILE ${DEBUG_MAKEFILES})
            file(READ "${DEBUG_MAKEFILE}" _contents)
            string(REPLACE "zlib.lib" "zlibd.lib" _contents "${_contents}")
            string(REPLACE "installed\\${TARGET_TRIPLET}\\lib" "installed\\${TARGET_TRIPLET}\\debug\\lib" _contents "${_contents}")
            string(REPLACE "/LIBPATH:${NATIVE_INSTALLED_DIR}\\debug\\lib" "/LIBPATH:${NATIVE_INSTALLED_DIR}\\debug\\lib\\manual-link /LIBPATH:${NATIVE_INSTALLED_DIR}\\debug\\lib shell32.lib" _contents "${_contents}")
            string(REPLACE "tools\\qt5\\qmlcachegen.exe" "tools\\qt5-declarative\\qmlcachegen.exe" _contents "${_contents}")
            string(REPLACE "tools/qt5/qmlcachegen" "tools/qt5-declarative/qmlcachegen" _contents "${_contents}")
            string(REPLACE "debug\\lib\\Qt5Bootstrap.lib" "tools\\qt5\\Qt5Bootstrap.lib" _contents "${_contents}")
            string(REPLACE "lib\\Qt5Bootstrap.lib" "tools\\qt5\\Qt5Bootstrap.lib" _contents "${_contents}")
            string(REPLACE " Qt5Bootstrap.lib " " ${NATIVE_INSTALLED_DIR}\\tools\\qt5\\Qt5Bootstrap.lib Ole32.lib Netapi32.lib Advapi32.lib ${NATIVE_INSTALLED_DIR}\\lib\\zlib.lib Shell32.lib " _contents "${_contents}")
            file(WRITE "${DEBUG_MAKEFILE}" "${_contents}")
        endforeach()
    endif()

    run_jom("${_csc_DEBUG_TARGETS}" ${_csc_BUILD_LOGNAME} dbg)

    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/lib;${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/tools/qt5;${ENV_PATH_BACKUP}")
    if(NOT _csc_SKIP_MAKEFILES)
        run_jom(qmake_all makefiles rel)

        #Store release makefile path
        file(GLOB_RECURSE RELEASE_MAKEFILES ${RELEASE_DIR}/*Makefile*)

        foreach(RELEASE_MAKEFILE ${RELEASE_MAKEFILES})
            file(READ "${RELEASE_MAKEFILE}" _contents)
            string(REPLACE "/LIBPATH:${NATIVE_INSTALLED_DIR}\\lib" "/LIBPATH:${NATIVE_INSTALLED_DIR}\\lib\\manual-link /LIBPATH:${NATIVE_INSTALLED_DIR}\\lib shell32.lib" _contents "${_contents}")
            string(REPLACE "tools\\qt5\\qmlcachegen.exe" "tools\\qt5-declarative\\qmlcachegen.exe" _contents "${_contents}")
            string(REPLACE "tools/qt5/qmlcachegen" "tools/qt5-declarative/qmlcachegen" _contents "${_contents}")
            string(REPLACE "debug\\lib\\Qt5Bootstrap.lib" "tools\\qt5\\Qt5Bootstrap.lib" _contents "${_contents}")
            string(REPLACE "lib\\Qt5Bootstrap.lib" "tools\\qt5\\Qt5Bootstrap.lib" _contents "${_contents}")
            string(REPLACE " Qt5Bootstrap.lib " " ${NATIVE_INSTALLED_DIR}\\tools\\qt5\\Qt5Bootstrap.lib Ole32.lib Netapi32.lib Advapi32.lib ${NATIVE_INSTALLED_DIR}\\lib\\zlib.lib Shell32.lib " _contents "${_contents}")
            file(WRITE "${RELEASE_MAKEFILE}" "${_contents}")
        endforeach()
    endif()

    run_jom("${_csc_RELEASE_TARGETS}" ${_csc_BUILD_LOGNAME} rel)
    
    # Restore the original value of ENV{PATH}
    set(ENV{PATH} "${ENV_PATH_BACKUP}")
    set(ENV{_CL_} "${ENV_CL_BACKUP}")
endfunction()

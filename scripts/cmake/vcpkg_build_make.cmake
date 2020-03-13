## # vcpkg_build_make
##
## Build a linux makefile project.
##
## ## Usage:
## ```cmake
## vcpkg_build_make([TARGET <target>])
## ```
##
## ### TARGET
## The target passed to the configure/make build command (`./configure/make/make install`). If not specified, no target will
## be passed.
##
## ### ADD_BIN_TO_PATH
## Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.
##
## ## Notes:
## This command should be preceeded by a call to [`vcpkg_configure_make()`](vcpkg_configure_make.md).
## You can use the alias [`vcpkg_install_make()`](vcpkg_configure_make.md) function if your CMake script supports the
## "install" target
##
## ## Examples
##
## * [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
## * [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
## * [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
## * [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
function(vcpkg_build_make)
    cmake_parse_arguments(_bc "ADD_BIN_TO_PATH;ENABLE_INSTALL" "LOGFILE_ROOT" "" ${ARGN})

    if(NOT _bc_LOGFILE_ROOT)
        set(_bc_LOGFILE_ROOT "build")
    endif()
    
    if (_VCPKG_PROJECT_SUBPATH)
        set(_VCPKG_PROJECT_SUBPATH /${_VCPKG_PROJECT_SUBPATH}/)
    endif()
    
    if(WIN32)
        set(_VCPKG_PREFIX ${CURRENT_PACKAGES_DIR})
        set(_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
    else()
        string(REPLACE " " "\ " _VCPKG_PREFIX "${CURRENT_PACKAGES_DIR}")
        string(REPLACE " " "\ " _VCPKG_INSTALLED "${CURRENT_INSTALLED_DIR}")
    endif()
    
    set(MAKE )
    set(MAKE_OPTS )
    set(INSTALL_OPTS )
    if (CMAKE_HOST_WIN32)
        set(PATH_GLOBAL "$ENV{PATH}")
        # These should be moved into the portfile!
        # vcpkg_find_acquire_program(YASM)
        # get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        # vcpkg_add_to_path("${YASM_EXE_PATH}")
        # vcpkg_find_acquire_program(PERL)
        # get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
        # vcpkg_add_to_path("${PERL_EXE_PATH}")
        
        vcpkg_add_to_path(PREPEND "${SCRIPTS}/buildsystems/make_wrapper")
        vcpkg_acquire_msys(MSYS_ROOT)
        find_program(MAKE make REQUIRED) #mingw32-make
        set(MAKE_COMMAND "${MAKE}")
        set(MAKE_OPTS ${_bc_MAKE_OPTIONS} -j ${VCPKG_CONCURRENCY} --trace -f makefile all)

        string(REPLACE " " "\\\ " _VCPKG_PACKAGE_PREFIX ${CURRENT_PACKAGES_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PACKAGE_PREFIX "${_VCPKG_PACKAGE_PREFIX}")
        set(INSTALL_OPTS -j ${VCPKG_CONCURRENCY} --trace -f makefile install DESTDIR=${_VCPKG_PACKAGE_PREFIX})
        #TODO: optimize for install-data (release) and install-exec (release/debug)
    else()
        # Compiler requriements
        # set(MAKE_BASH)
        find_program(MAKE make REQUIRED)
        set(MAKE_COMMAND "${MAKE}")
        # Set make command and install command
        set(MAKE_OPTS ${_bc_MAKE_OPTIONS} V=1 -j ${VCPKG_CONCURRENCY} -f makefile all)
        set(INSTALL_OPTS -j ${VCPKG_CONCURRENCY} install DESTDIR=${CURRENT_PACKAGES_DIR})
    endif()
    
    # Backup enviromnent variables
    set(C_FLAGS_BACKUP "$ENV{CFLAGS}")
    set(CXX_FLAGS_BACKUP "$ENV{CXXFLAGS}")
    set(LD_FLAGS_BACKUP "$ENV{LDFLAGS}")
    set(INCLUDE_PATH_BACKUP "$ENV{INCLUDE_PATH}")
    set(INCLUDE_BACKUP "$ENV{INCLUDE}")
    set(C_INCLUDE_PATH_BACKUP "$ENV{C_INCLUDE_PATH}")
    set(CPLUS_INCLUDE_PATH_BACKUP "$ENV{CPLUS_INCLUDE_PATH}")
    set(LD_LIBRARY_PATH_BACKUP "$ENV{LD_LIBRARY_PATH}")
    set(LIBRARY_PATH_BACKUP "$ENV{LIBRARY_PATH}")
    set(LIBPATH_BACKUP "$ENV{LIBPATH}")
    
    # Setup include enviromnent
    set(ENV{INCLUDE} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_BACKUP}")
    set(ENV{INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_PATH_BACKUP}")
    set(ENV{C_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${C_INCLUDE_PATH_BACKUP}")
    set(ENV{CPLUS_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${CPLUS_INCLUDE_PATH_BACKUP}")

    # Setup global flags
    set(C_FLAGS_GLOBAL "$ENV{CFLAGS} ${VCPKG_C_FLAGS}")
    set(CXX_FLAGS_GLOBAL "$ENV{CXXFLAGS} ${VCPKG_CXX_FLAGS}")
    set(LD_FLAGS_GLOBAL "$ENV{LDFLAGS} ${VCPKG_LINKER_FLAGS}")
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        string(APPEND C_FLAGS_GLOBAL " -fPIC")
        string(APPEND CXX_FLAGS_GLOBAL " -fPIC")
    else()
        string(APPEND C_FLAGS_GLOBAL " /D_WIN32_WINNT=0x0601 /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS")
        string(APPEND CXX_FLAGS_GLOBAL " /D_WIN32_WINNT=0x0601 /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS")
        string(APPEND LD_FLAGS_GLOBAL " /VERBOSE -no-undefined")
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
            string(APPEND LD_FLAGS_GLOBAL " /machine:x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            string(APPEND LD_FLAGS_GLOBAL " /machine:x86")
        endif()
    endif()
    
    foreach(BUILDTYPE "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            if(BUILDTYPE STREQUAL "debug")
                # Skip debug generate
                if (_VCPKG_NO_DEBUG)
                    continue()
                endif()
                set(SHORT_BUILDTYPE "-dbg")
                set(CMAKE_BUILDTYPE "DEBUG")
            else()
                # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                if (_VCPKG_NO_DEBUG)
                    set(SHORT_BUILDTYPE "")
                else()
                    set(SHORT_BUILDTYPE "-rel")
                endif()
                set(CMAKE_BUILDTYPE "RELEASE")
            endif()
            
            if (CMAKE_HOST_WIN32)
                # In windows we can remotely call make
                set(WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
            else()
                set(WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}${_VCPKG_PROJECT_SUBPATH}")
            endif()
    
            message(STATUS "Building ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")

            if(_bc_ADD_BIN_TO_PATH)
                set(_BACKUP_ENV_PATH "$ENV{PATH}")
                if(BUILDTYPE STREQUAL "debug")
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin")
                else()
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin")
                endif()
            endif()

            if (CMAKE_HOST_WIN32)
                set(TMP_CFLAGS "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_${CMAKE_BUILDTYPE}}")
                string(REGEX REPLACE "[ \t]+/" " -" TMP_CFLAGS "${TMP_CFLAGS}")
                set(ENV{CFLAGS} ${TMP_CFLAGS})
                
                set(TMP_CXXFLAGS "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_${CMAKE_BUILDTYPE}}")
                string(REGEX REPLACE "[ \t]+/" " -" TMP_CXXFLAGS "${TMP_CXXFLAGS}")
                set(ENV{CXXFLAGS} ${TMP_CXXFLAGS})
                
                set(TMP_LDFLAGS "${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${CMAKE_BUILDTYPE}}")
                string(REGEX REPLACE "[ \t]+/" " -" TMP_LDFLAGS "${TMP_LDFLAGS}")
                set(ENV{LDFLAGS} ${TMP_LDFLAGS})
                
                string(REPLACE " " "\ " _VCPKG_INSTALLED_PKGCONF "${CURRENT_INSTALLED_DIR}")
                string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_PKGCONF "${_VCPKG_INSTALLED_PKGCONF}")
                string(REPLACE "\\" "/" _VCPKG_INSTALLED_PKGCONF "${_VCPKG_INSTALLED_PKGCONF}")
                if(BUILDTYPE STREQUAL "debug")
                    set(ENV{VCPKG_PKG_PREFIX} ${_VCPKG_INSTALLED_PKGCONF}/debug)
                else()
                    set(ENV{VCPKG_PKG_PREFIX} ${_VCPKG_INSTALLED_PKGCONF})
                endif()
                
            else()
                set(ENV{CFLAGS} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_${CMAKE_BUILDTYPE}}")
                set(ENV{CXXFLAGS} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_${CMAKE_BUILDTYPE}}")

                if(BUILDTYPE STREQUAL "debug")
                    set(ENV{LDFLAGS} "-L${_VCPKG_INSTALLED}/debug/lib/ -L${_VCPKG_INSTALLED}/debug/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${CMAKE_BUILDTYPE}}")
                    set(ENV{LIBRARY_PATH} "${_VCPKG_INSTALLED}/debug/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LIBRARY_PATH_BACKUP}")
                    set(ENV{LD_LIBRARY_PATH} "${_VCPKG_INSTALLED}/debug/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LD_LIBRARY_PATH_BACKUP}")
                else()
                    set(ENV{LDFLAGS} "-L${_VCPKG_INSTALLED}/lib/ -L${_VCPKG_INSTALLED}/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${CMAKE_BUILDTYPE}}")
                    set(ENV{LIBRARY_PATH} "${_VCPKG_INSTALLED}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LIBRARY_PATH_BACKUP}")
                    set(ENV{LD_LIBRARY_PATH} "${_VCPKG_INSTALLED}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LD_LIBRARY_PATH_BACKUP}")
                endif()
            endif()
            
            if(MAKE_BASH)
                set(MAKE_CMD_LINE "${MAKE_COMMAND} ${MAKE_OPTS}")
            else()
                set(MAKE_CMD_LINE ${MAKE_COMMAND} ${MAKE_OPTS})
            endif()
            vcpkg_execute_build_process(
                    COMMAND ${MAKE_BASH} ${MAKE_CMD_LINE}
                    WORKING_DIRECTORY "${WORKING_DIRECTORY}"
                    LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )

            if(_bc_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${_BACKUP_ENV_PATH}")
            endif()
        endif()
    endforeach()

    if (_bc_ENABLE_INSTALL OR TRUE)
        foreach(BUILDTYPE "debug" "release")
            if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
                if(BUILDTYPE STREQUAL "debug")
                    # Skip debug generate
                    if (_VCPKG_NO_DEBUG)
                        continue()
                    endif()
                    set(SHORT_BUILDTYPE "-dbg")
                else()
                    # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                    if (_VCPKG_NO_DEBUG)
                        set(SHORT_BUILDTYPE "")
                    else()
                        set(SHORT_BUILDTYPE "-rel")
                    endif()
                endif()
            
                message(STATUS "Installing ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
                
                if(MAKE_BASH)
                    set(MAKE_CMD_LINE "${MAKE_COMMAND} ${INSTALL_OPTS}")
                else()
                    set(MAKE_CMD_LINE ${MAKE_COMMAND} ${INSTALL_OPTS})
                endif()
                
                set(WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
                vcpkg_execute_build_process(
                    COMMAND ${MAKE_BASH} ${MAKE_CMD_LINE}
                    WORKING_DIRECTORY "${WORKING_DIRECTORY}"
                    LOGNAME "install-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )

            endif()
        endforeach()
    endif()

    # Restore enviromnent
    set(ENV{CFLAGS} "${C_FLAGS_BACKUP}")
    set(ENV{CXXFLAGS} "${CXX_FLAGS_BACKUP}")
    set(ENV{LDFLAGS} "${LD_FLAGS_BACKUP}")

    set(ENV{INCLUDE} "${INCLUDE_BACKUP}")
    set(ENV{INCLUDE_PATH} "${INCLUDE_PATH_BACKUP}")
    set(ENV{C_INCLUDE_PATH} "${C_INCLUDE_PATH_BACKUP}")
    set(ENV{CPLUS_INCLUDE_PATH} "${CPLUS_INCLUDE_PATH_BACKUP}")
    set(ENV{LIBRARY_PATH} "${LIBRARY_PATH_BACKUP}")
    set(ENV{LD_LIBRARY_PATH} "${LD_LIBRARY_PATH_BACKUP}")

    if (CMAKE_HOST_WIN32)
        set(ENV{PATH} "${PATH_GLOBAL}")
    endif()
    
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALL_PREFIX "${CURRENT_INSTALLED_DIR}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}_tmp")
    file(RENAME "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}_tmp")
    file(RENAME "${CURRENT_PACKAGES_DIR}_tmp${_VCPKG_INSTALL_PREFIX}/" "${CURRENT_PACKAGES_DIR}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}_tmp")
endfunction()

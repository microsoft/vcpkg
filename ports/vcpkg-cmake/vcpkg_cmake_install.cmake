include_guard(GLOBAL)

function(vcpkg_cmake_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(args)
    foreach(arg IN ITEMS DISABLE_PARALLEL ADD_BIN_TO_PATH)
        if(arg_${arg})
            list(APPEND args "${arg}")
        endif()
    endforeach()

    vcpkg_cmake_build(
        ${args}
        LOGFILE_BASE install
        TARGET install
    )

    # check whether a split build was requested and executed
    if (Z_VCPKG_OSX_SPLIT_BUILD)
        list(LENGTH VCPKG_OSX_ARCHITECTURES ARCHITECTURE_LENGTH)
        if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin" AND ${ARCHITECTURE_LENGTH} GREATER 1)
            # if we performed a split build, we'll need to zip those up
            # using the lipo tool, start by looking that up
            find_program(LIPO_EXECUTABLE lipo REQUIRED)

            foreach(buildtype IN ITEMS debug release)
                if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL buildtype)
                    if(buildtype STREQUAL "debug")
                        set(SHORT_BUILD_TYPE "dbg")
                        set(PACKAGE_DIR_SUFFIX "/debug")
                    else()
                        set(SHORT_BUILD_TYPE "rel")
                        set(PACKAGE_DIR_SUFFIX "")
                    endif()

                    set(INSTALL_DIRECTORIES)

                    foreach(OSX_ARCHITECTURE ${VCPKG_OSX_ARCHITECTURES})
                        if (NOT INSTALL_DIRECTORIES)
                            set(INSTALL_DIRECTORY "${CURRENT_PACKAGES_DIR}${PACKAGE_DIR_SUFFIX}")
                        else()
                            set(INSTALL_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${OSX_ARCHITECTURE}-${SHORT_BUILD_TYPE}-install")
                        endif()

                        list(APPEND INSTALL_DIRECTORIES "${INSTALL_DIRECTORY}")
                    endforeach()

                    # note: we cannot glob the library files in a single operation, due to a cmake
                    # bug in file globbing, a pattern like "*.{a,dylib}" does not work.
                    # also note that we are using the _last_ directory set, which is inside the
                    # buildtree, and not the normal packages directory, since that would likely
                    # also contain other installed libraries
                    file(GLOB_RECURSE STATIC_LIBS RELATIVE "${INSTALL_DIRECTORY}" "${INSTALL_DIRECTORY}/lib/*.a")
                    file(GLOB_RECURSE SHARED_LIBS RELATIVE "${INSTALL_DIRECTORY}" "${INSTALL_DIRECTORY}/lib/*.dylib")
                    file(GLOB_RECURSE EXECUTABLES RELATIVE "${INSTALL_DIRECTORY}" "${INSTALL_DIRECTORY}/bin/*")

                    # filter out symlinks to get the real libraries to process
                    foreach (FOUND_LIBRARY ${STATIC_LIBS} ${SHARED_LIBS} ${EXECUTABLES})
                        if (NOT IS_SYMLINK "${INSTALL_DIRECTORY}/${FOUND_LIBRARY}")
                            # now build the command to join the files
                            set(LIPO_ARGUMENTS "-create" "-output" "${CURRENT_PACKAGES_DIR}${PACKAGE_DIR_SUFFIX}/${FOUND_LIBRARY}")

                            # add all architectures to the library
                            foreach (OSX_ARCHITECTURE ${VCPKG_OSX_ARCHITECTURES})
                                list(POP_FRONT INSTALL_DIRECTORIES ARCH_INSTALL_DIRECTORY)
                                list(APPEND LIPO_ARGUMENTS "-arch" "${OSX_ARCHITECTURE}" "${ARCH_INSTALL_DIRECTORY}/${FOUND_LIBRARY}")
                            endforeach()

                            # now join the found libraries
                            vcpkg_execute_required_process(
                                COMMAND ${LIPO_EXECUTABLE} ${LIPO_ARGUMENTS}
                                WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}
                                LOGNAME "lipo-${TARGET_TRIPLET}"
                            )
                        endif()
                    endforeach()
                endif()
            endforeach()
        endif()
    endif()
endfunction()

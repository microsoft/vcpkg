# this function implicitly reads qt_build_submodule_KEEP_TOOL_DEPS
function(qt_build_submodule SOURCE_PATH)
    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV{_CL_} "/utf-8")

    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
    vcpkg_add_to_path("${PYTHON2_EXE_PATH}")

    vcpkg_configure_qmake(SOURCE_PATH ${SOURCE_PATH} ${ARGV})

    vcpkg_build_qmake(SKIP_MAKEFILES)

    #Fix the installation location within the makefiles
    qt_fix_makefile_install("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/")
    qt_fix_makefile_install("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    
    #Install the module files
    vcpkg_build_qmake(TARGETS install SKIP_MAKEFILES BUILD_LOGNAME install)

    qt_fix_cmake(${CURRENT_PACKAGES_DIR} ${PORT})
    vcpkg_fixup_pkgconfig() # Needs further investigation if this is enough!

    #Replace with VCPKG variables if PR #7733 is merged
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

    function(remove_if_empty dir)
        file(GLOB items "${dir}/*")
        vcpkg_list(LENGTH items len)
        if(len EQUAL 0)
            file(REMOVE_RECURSE "${dir}")
        endif()
    endfunction()

    function(remove_if_empty_recurse dir)
        file(GLOB items "${dir}/*")
        foreach(item IN LISTS items)
            if(IS_DIRECTORY "${item}")
                remove_if_empty_recurse("${item}")
            endif()
        endforeach()
        file(GLOB items "${dir}/*")
        vcpkg_list(LENGTH items len)
        if(len EQUAL 0)
            file(REMOVE_RECURSE "${dir}")
        endif()
    endfunction()

    foreach(_buildname ${BUILDTYPES})
        set(CURRENT_BUILD_PACKAGE_DIR "${CURRENT_PACKAGES_DIR}${_path_suffix_${_buildname}}")
        #Fix PRL files 
        file(GLOB_RECURSE PRL_FILES "${CURRENT_BUILD_PACKAGE_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5${_path_suffix_${_buildname}}/lib/*.prl" 
                                    "${CURRENT_PACKAGES_DIR}/tools/qt5${_path_suffix_${_buildname}}/mkspecs/*.pri")
        qt_fix_prl("${CURRENT_BUILD_PACKAGE_DIR}" "${PRL_FILES}")

        # This makes it impossible to use the build tools in any meaningful way. qt5 assumes they are all in one folder!
        # So does the Qt VS Plugin which even assumes all of the in a bin folder  
        #Move tools to the correct directory
        #if(EXISTS ${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5)
        #    file(RENAME ${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5 ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        #endif()

        # Move deployed binaries to tools
        file(GLOB PACKAGE_EXES ${CURRENT_BUILD_PACKAGE_DIR}/bin/*)
        if(PACKAGE_EXES)
            file(MAKE_DIRECTORY "${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5/bin")
            file(COPY ${PACKAGE_EXES} DESTINATION "${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5/bin")
        endif()
        if(EXISTS "${CURRENT_BUILD_PACKAGE_DIR}/plugins")
            file(MAKE_DIRECTORY "${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5/bin")
            file(COPY "${CURRENT_BUILD_PACKAGE_DIR}/plugins" DESTINATION "${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5/bin")
        endif()
        if(EXISTS "${CURRENT_BUILD_PACKAGE_DIR}/qml")
            file(MAKE_DIRECTORY "${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5/bin")
            file(COPY "${CURRENT_BUILD_PACKAGE_DIR}/qml" DESTINATION "${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5/bin")
        endif()

        #cleanup empty folders
        remove_if_empty("${CURRENT_BUILD_PACKAGE_DIR}/lib")
        remove_if_empty("${CURRENT_BUILD_PACKAGE_DIR}/bin")
    endforeach()

    file(GLOB_RECURSE my_bins RELATIVE "${CURRENT_PACKAGES_DIR}/tools/qt5/bin" "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/*")
    file(GLOB plugin_dirs "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/plugins/*")
    foreach(plugin_dir IN LISTS plugin_dirs)
        file(GLOB plugin_bins RELATIVE "${plugin_dir}" "${plugin_dir}/*")
        vcpkg_copy_tool_dependencies("${plugin_dir}")
        file(REMOVE_RECURSE "${plugin_dir}/plugins" "${plugin_dir}/qml")
        file(GLOB expected_bins RELATIVE "${plugin_dir}" "${plugin_dir}/*")
        foreach(bin IN LISTS expected_bins)
            if("${bin}" IN_LIST plugin_bins)
                # Deployed by me, continuing
                continue()
            endif()
            if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/${bin}")
                file(REMOVE "${plugin_dir}/${bin}")
            else()
                file(RENAME "${plugin_dir}/${bin}" "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/${bin}")
            endif()
        endforeach()
    endforeach()
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/qt5/bin")
    file(GLOB_RECURSE required_bins RELATIVE "${CURRENT_PACKAGES_DIR}/tools/qt5/bin" "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/*")
    foreach(bin IN LISTS required_bins)
        if("${bin}" IN_LIST my_bins)
            # Deployed by me, continuing
            continue()
        endif()
        get_filename_component(stem "${bin}" NAME_WE)
        if("${stem}" IN_LIST qt_build_submodule_KEEP_TOOL_DEPS OR "lib${stem}" IN_LIST qt_build_submodule_KEEP_TOOL_DEPS)
            # This is an external dependency that I am expected to deploy
            continue()
        endif()
        if(EXISTS "${CURRENT_INSTALLED_DIR}/tools/qt5/bin/${bin}")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/${bin}")
        else()
            # I expected a dependency that doesn't currently exist to have already been deployed
            message(FATAL_ERROR "Port ${PORT} expected ${CURRENT_INSTALLED_DIR}/tools/qt5/bin/${bin} to be deployed by another port")
        endif()
    endforeach()
    file(GLOB programs "${CURRENT_PACKAGES_DIR}/bin/*.exe" "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    if(programs)
        file(REMOVE ${programs})
    endif()
    remove_if_empty_recurse("${CURRENT_PACKAGES_DIR}/bin")
    remove_if_empty_recurse("${CURRENT_PACKAGES_DIR}/tools")
    remove_if_empty_recurse("${CURRENT_PACKAGES_DIR}/qml")
    remove_if_empty_recurse("${CURRENT_PACKAGES_DIR}/debug")
endfunction()

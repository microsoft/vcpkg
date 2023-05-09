function(build_msvc build_type source_path)
    if(build_type STREQUAL "DEBUG")
        set(label "${TARGET_TRIPLET}-dbg")
        set(packages_dir "${CURRENT_PACKAGES_DIR}/debug")
    else()
        set(label "${TARGET_TRIPLET}-rel")
        set(packages_dir "${CURRENT_PACKAGES_DIR}")
    endif()

    set(build_path "${CURRENT_BUILDTREES_DIR}/${label}")
    file(REMOVE_RECURSE "${build_path}")
    file(COPY "${source_path}/" DESTINATION "${build_path}")

    message(STATUS "Patching ${label}")
    vcpkg_apply_patches(
        SOURCE_PATH "${build_path}"
        PATCHES
            patches/windows/Solution_${build_type}.patch
            patches/windows/python3_build_${build_type}.patch
    )
    vcpkg_replace_string("${build_path}/src/tools/msvc/MSBuildProject.pm" "perl" "\"${PERL}\"")

    file(COPY "${CURRENT_PORT_DIR}/config.pl" DESTINATION "${build_path}/src/tools/msvc")
    configure_file("${CURRENT_PORT_DIR}/libpq.props.in" "${build_path}/libpq.props" @ONLY)

    set(config_file "${build_path}/src/tools/msvc/config.pl")
    file(READ "${config_file}" _contents)
    if("icu" IN_LIST FEATURES)
        string(REPLACE "icu       => undef" "icu      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("lz4" IN_LIST FEATURES)
        string(REPLACE "lz4       => undef" "lz4       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("nls" IN_LIST FEATURES)
        string(REPLACE "nls       => undef" "nls      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES gettext)
        vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    endif()
    if("openssl" IN_LIST FEATURES)
        string(REPLACE "openssl   => undef" "openssl   => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("python" IN_LIST FEATURES)
        #vcpkg_find_acquire_program(PYTHON3)
        #get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
        #vcpkg_add_to_path("${PYTHON3_EXE_PATH}")
        string(REPLACE "python    => undef" "python    => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("tcl" IN_LIST FEATURES)
        string(REPLACE "tcl       => undef" "tcl       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("xml" IN_LIST FEATURES)
        string(REPLACE "xml       => undef" "xml       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        string(REPLACE "iconv     => undef" "iconv     => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("xslt" IN_LIST FEATURES)
        string(REPLACE "xslt      => undef" "xslt      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("zlib" IN_LIST FEATURES)
        string(REPLACE "zlib      => undef" "zlib      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("zstd" IN_LIST FEATURES)
        string(REPLACE "zstd      => undef" "zstd      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    file(WRITE "${config_file}" "${_contents}")

    vcpkg_get_windows_sdk(VCPKG_TARGET_PLATFORM_VERSION)
    set(ENV{MSBFLAGS}"/p:PlatformToolset=${VCPKG_PLATFORM_TOOLSET}
        /p:VCPkgLocalAppDataDisabled=true
        /p:UseIntelMKL=No
        /p:WindowsTargetPlatformVersion=${VCPKG_TARGET_PLATFORM_VERSION}
        /m
        /p:ForceImportBeforeCppTargets=\"${SCRIPTS}/buildsystems/msbuild/vcpkg.targets\"
        /p:ForceImportAfterCppTargets=\"${build_path}/libpq.props\"
        /p:VcpkgTriplet=${TARGET_TRIPLET}
        /p:VcpkgCurrentInstalledDir=\"${CURRENT_INSTALLED_DIR}\""
    )
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(ENV{MSBFLAGS} "$ENV{MSBFLAGS} /p:Platform=Win32")
    endif()

    message(STATUS "Building ${label}")
    if(HAS_TOOLS)
        vcpkg_execute_required_process(
            COMMAND "${PERL}" build.pl ${build_type}
            WORKING_DIRECTORY "${build_path}/src/tools/msvc"
            LOGNAME "build-${label}"
        )
    else()
        foreach(lib IN ITEMS libpq libecpg_compat)
            vcpkg_execute_required_process(
                COMMAND "${PERL}" build.pl ${build_type} ${lib}
                WORKING_DIRECTORY "${build_path}/src/tools/msvc"
                LOGNAME "build-${lib}-${label}"
            )
        endforeach()
    endif()

    message(STATUS "Installing ${label}")
    vcpkg_execute_required_process(
        COMMAND "${PERL}" install.pl "${packages_dir}" client
        WORKING_DIRECTORY "${build_path}/src/tools/msvc"
        LOGNAME "install-${label}"
    )
endfunction()

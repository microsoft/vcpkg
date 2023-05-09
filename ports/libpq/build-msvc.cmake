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

    vcpkg_get_windows_sdk(VCPKG_TARGET_PLATFORM_VERSION)
    set(ENV{MSBFLAGS} "/p:PlatformToolset=${VCPKG_PLATFORM_TOOLSET}
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

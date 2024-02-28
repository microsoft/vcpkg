vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openfx
    TAG OFX_Release_1_4_TAG
    REF a355991
    SHA512 cda67fd3aa30fb01a580e8c42cd06284f83e5ae06e95c4fda7adb09f4130853aedb3d908b6c465025415973b45b72b17711c646b5b6faeff988b60ad80b0a4c2
)
message("OpenFX Path:")
message(${SOURCE_PATH})

# Read the original solution file
#file(READ ${SOURCE_PATH}/HostSupport/HostSupport.sln HOSTSUPPORT_SOLUTION_CONTENT)

# Update the solution file format to Visual Studio 2017
#string(REPLACE "# Visual Studio 2005" "# Visual Studio 15" HOSTSUPPORT_SOLUTION_CONTENT ${HOSTSUPPORT_SOLUTION_CONTENT})
#string(REPLACE "Microsoft Visual Studio Solution File, Format Version 9.00" "Microsoft Visual Studio Solution File, Format Version 12.00" HOSTSUPPORT_SOLUTION_CONTENT ${HOSTSUPPORT_SOLUTION_CONTENT})
# Append a new string to the solution file content
#string(APPEND HOSTSUPPORT_SOLUTION_CONTENT "\n VisualStudioVersion = 15.0.28307.852 \n")
#string(APPEND HOSTSUPPORT_SOLUTION_CONTENT "\n MinimumVisualStudioVersion = 10.0.40219.1 \n")

# Write the updated solution file
#file(WRITE ${SOURCE_PATH}/HostSupport/HostSupport.sln ${HOSTSUPPORT_SOLUTION_CONTENT})
#set(devenv_cmd
#    devenv /upgrade HostSupport.sln
#)
#execute_process(
#    COMMAND ${devenv_cmd}
#    WORKING_DIRECTORY ${SOURCE_PATH}/HostSupport
#)

#if (MSVC)
    # Define the build command for HostSupport project
    set(build_cmd
        msbuild HostSupport.sln /p:Configuration=Release /p:Platform=x64 /p:OutputPath=$(SolutionDir)$(Configuration)
    )

    # Add custom build step to build HostSupport
    execute_process(
        COMMAND ${build_cmd}
        WORKING_DIRECTORY ${SOURCE_PATH}/HostSupport/
        RESULT_VARIABLE build_result
    )

    if (NOT build_result EQUAL 0)
        message(FATAL_ERROR "Failed to build HostSupport project")
    endif()
#endif()

#vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
#vcpkg_cmake_install()
#vcpkg_copy_pdbs()
#vcpkg_fixup_pkgconfig()


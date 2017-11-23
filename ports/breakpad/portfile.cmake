# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/breakpad)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "google/breakpad"
    REF 2aaeead73fbc70860c6bc0ff477500f84ab595e9
    SHA512 fe4f34372e638b5d1f1414bdaca459a77c1314087a979fd881d491edac2417a462a4be367b52ea0451b5c9df90e1de1b90a835724755e5bfe75f405b9544392a
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-Fix-Breakpad-for-vcpkg-build.patch"
)

find_program(GIT git)
if(NOT GIT)
    message(FATAL_ERROR "gyp not found!")
endif()
#message(STATUS "git found at: ${GIT}")
#message(STATUS "cmake found at: ${CMAKE_COMMAND}")

execute_process(
    COMMAND ${GIT} clone --depth 1 -b release-1.8.0 https://github.com/google/googletest.git testing
    WORKING_DIRECTORY ${SOURCE_PATH}/src
    ERROR_QUIET
)

#message(STATUS "PATH: $ENV{PATH}")
vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_PATH ${PYTHON2} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON2_PATH}")

#find_program(GYP gyp)
#if(NOT GYP)
#    message(FATAL_ERROR "gyp not found!")
#endif()
file(MAKE_DIRECTORY ${SOURCE_PATH}/gyp)
# See "How to clone git repository with specific revision/changeset?" (stackoverflow.com)
# Note: execute_process runs multiple commands in parallel, but we need them to execute in sequence
execute_process(
    COMMAND ${GIT} init
    WORKING_DIRECTORY ${SOURCE_PATH}/gyp
    ERROR_QUIET
)
execute_process(
    COMMAND ${GIT} remote add origin https://chromium.googlesource.com/external/gyp
    WORKING_DIRECTORY ${SOURCE_PATH}/gyp
    ERROR_QUIET
)
execute_process(
    COMMAND ${GIT} fetch origin 5e2b3ddde7cda5eb6bc09a5546a76b00e49d888f --depth 1
    WORKING_DIRECTORY ${SOURCE_PATH}/gyp
    ERROR_QUIET
)
execute_process(
    COMMAND ${GIT} reset --hard FETCH_HEAD
    WORKING_DIRECTORY ${SOURCE_PATH}/gyp
    ERROR_QUIET
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}/gyp
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-Fix-gyp-for-building-with-VS-2017-vcpkg.patch"
)

set(GYP_PATH "${SOURCE_PATH}/gyp/")

execute_process(
    COMMAND ${PYTHON2} "${GYP_PATH}/gyp_main.py" 
        client/windows/breakpad_client.gyp 
        --no-circular-check --depth=. -f msvs -G msvs_version=2017
    WORKING_DIRECTORY ${SOURCE_PATH}/src/
    OUTPUT_VARIABLE GYP_OUTPUT
    ERROR_VARIABLE GYP_ERROR_OUTPUT
    RESULT_VARIABLE error_code
)

if (error_code)
    message(STATUS "Output: ${GYP_OUTPUT}")
    message(STATUS "Error: ${GYP_ERROR_OUTPUT}")
    message(FATAL_ERROR "Failed to build Breakpad MSVC projects")
endif()

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/src/client/windows/breakpad_client.sln
    PLATFORM ${MSBUILD_PLATFORM}
    RELEASE_CONFIGURATION Release
    DEBUG_CONFIGURATION Debug
    OPTIONS /v:normal /detailedsummary
)

# Headers (list constructed by setting /showIncludes, and filtering the output)
set(header_list
    client/windows/common/ipc_protocol.h
    client/windows/crash_generation/crash_generation_client.h
    client/windows/handler/exception_handler.h
    common/basictypes.h
    common/scoped_ptr.h
    common/using_std_string.h
    common/windows/string_utils-inl.h
    google_breakpad/common/breakpad_types.h
    google_breakpad/common/minidump_cpu_amd64.h
    google_breakpad/common/minidump_cpu_arm.h
    google_breakpad/common/minidump_cpu_arm64.h
    google_breakpad/common/minidump_cpu_mips.h
    google_breakpad/common/minidump_cpu_ppc.h
    google_breakpad/common/minidump_cpu_ppc64.h
    google_breakpad/common/minidump_cpu_sparc.h
    google_breakpad/common/minidump_cpu_x86.h
    google_breakpad/common/minidump_exception_linux.h
    google_breakpad/common/minidump_exception_mac.h
    google_breakpad/common/minidump_exception_ps3.h
    google_breakpad/common/minidump_exception_solaris.h
    google_breakpad/common/minidump_exception_win32.h
    google_breakpad/common/minidump_format.h
    google_breakpad/processor/code_module.h
    google_breakpad/processor/code_modules.h
    google_breakpad/processor/dump_context.h
    google_breakpad/processor/dump_object.h
    google_breakpad/processor/memory_region.h
    google_breakpad/processor/minidump.h
    google_breakpad/processor/proc_maps_linux.h
    processor/linked_ptr.h
)

function(install_headers_with_directory header_list)
    foreach(header ${header_list})
        #message(STATUS "header: ${header}")
        string(REGEX MATCH "(.*)/" dir ${header})
        #message(STATUS "dir: ${dir}")
        file(INSTALL ${SOURCE_PATH}/src/${header} 
            DESTINATION ${CURRENT_PACKAGES_DIR}/include/breakpad/${dir})
    endforeach()
endfunction()

install_headers_with_directory("${header_list}")

set(lib_list
    common.lib
    crash_generation_client.lib
    crash_generation_server.lib
    crash_report_sender.lib
    exception_handler.lib
    processor_bits.lib
)

foreach(lib ${lib_list})
    #message(STATUS "lib: ${lib}")
    file(INSTALL "${SOURCE_PATH}/src/client/windows/${MSBUILD_PLATFORM}/Release/lib/${lib}"
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL "${SOURCE_PATH}/src/client/windows/${MSBUILD_PLATFORM}/Debug/lib/${lib}"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endforeach()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/breakpad-config.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/breakpad)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/breakpad RENAME copyright)

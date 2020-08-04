vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF 31ebe2ac71400344a5db91ffc13c4ddfb7589f92    #v3.12.3
    SHA512 74e623547bb9448ccea29925172bf13fcbffab80eb02f58d248180000b4ae7249f0dee88bb4ef438857b0e1a96a600ab270ebf3b58568da28cbf97d8a2398297
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        fix-android-log.patch
        fix-static-build.patch
)

if(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(protobuf_BUILD_PROTOC_BINARIES OFF)
elseif(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_IS_MINGW AND NOT (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP))
    set(protobuf_BUILD_PROTOC_BINARIES OFF)
else()
    set(protobuf_BUILD_PROTOC_BINARIES ON)
endif()

if(NOT protobuf_BUILD_PROTOC_BINARIES AND NOT EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/protobuf)
    message(FATAL_ERROR "Cross-targetting protobuf requires the x86-windows protoc to be available. Please install protobuf:x86-windows first.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_STATIC_CRT OFF)
else()
  set(VCPKG_BUILD_STATIC_CRT ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
	zlib	protobuf_WITH_ZLIB
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=${VCPKG_BUILD_SHARED_LIBS}
        -Dprotobuf_MSVC_STATIC_RUNTIME=${VCPKG_BUILD_STATIC_CRT}
        -Dprotobuf_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_CMAKEDIR:STRING=share/protobuf
        -Dprotobuf_BUILD_PROTOC_BINARIES=${protobuf_BUILD_PROTOC_BINARIES}
         ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

# It appears that at this point the build hasn't actually finished. There is probably
# a process spawned by the build, therefore we need to wait a bit.

function(protobuf_try_remove_recurse_wait PATH_TO_REMOVE)
    file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    if (EXISTS "${PATH_TO_REMOVE}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
        file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    endif()
endfunction()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/include)

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
	vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake
		"\${_IMPORT_PREFIX}/bin/protoc${EXECUTABLE_SUFFIX}"
		"\${_IMPORT_PREFIX}/tools/protobuf/protoc${EXECUTABLE_SUFFIX}"
)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
    string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc${EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protobuf/protoc${EXECUTABLE_SUFFIX}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")
endif()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/share)

if(CMAKE_HOST_WIN32)
    if(protobuf_BUILD_PROTOC_BINARIES)
        file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
    else()
        file(COPY ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/${PORT} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    else()
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin/protoc.exe)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin/protoc.exe)
    endif()
else()
    file(GLOB EXECUTABLES ${CURRENT_PACKAGES_DIR}/bin/protoc*)
    foreach(E IN LISTS EXECUTABLES)
        file(INSTALL ${E} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
                PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_WRITE GROUP_EXECUTE WORLD_READ)
    endforeach()
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h
		"\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_"
		"\#ifndef PROTOBUF_USE_DLLS\n\#define PROTOBUF_USE_DLLS\n\#endif // PROTOBUF_USE_DLLS\n\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_"
)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_copy_pdbs()
set(packages protobuf protobuf-lite)
foreach(_package IN LISTS packages)
    set(_file ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${_package}.pc)
    if(EXISTS "${_file}")
        vcpkg_replace_string(${_file} "-l${_package}" "-l${_package}d")
    endif()
endforeach()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(SYSTEM_LIBRARIES SYSTEM_LIBRARIES pthread)
endif()
vcpkg_fixup_pkgconfig(${SYSTEM_LIBRARIES})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(PYTHON_VERSION_MAJOR  3)
set(PYTHON_VERSION_MINOR  6)
set(PYTHON_VERSION_PATCH  4)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH TEMP_SOURCE_PATH
    REPO python/cpython
    REF v${PYTHON_VERSION}
    SHA512 32cca5e344ee66f08712ab5533e5518f724f978ec98d985f7612d0bd8d7f5cac25625363c9eead192faf1806d4ea3393515f72ba962a2a0bed26261e56d8c637
    HEAD_REF master
)

if(WIN32)
vcpkg_apply_patches(
    SOURCE_PATH ${TEMP_SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0004-Fix-iomodule-for-RS4-SDK.patch
)
endif()

# We need per-triplet directories because we need to patch the project files differently based on the linkage
# Because the patches patch the same file, they have to be applied in the correct order
set(SOURCE_PATH "${TEMP_SOURCE_PATH}-Lib-${VCPKG_LIBRARY_LINKAGE}-crt-${VCPKG_CRT_LINKAGE}")
file(REMOVE_RECURSE ${SOURCE_PATH})
file(RENAME "${TEMP_SOURCE_PATH}" ${SOURCE_PATH})

if(WIN32)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0001-Static-library.patch
    )
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0002-Static-CRT.patch
    )
endif()
endif()

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(BUILD_ARCH "Win32")
    set(OUT_DIR "win32")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(BUILD_ARCH "x64")
    set(OUT_DIR "amd64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if(WIN32)
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/PCBuild/pythoncore.vcxproj
    PLATFORM ${BUILD_ARCH})
else()
message(STATUS "Configure ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ./configure --enable-shared
    WORKING_DIRECTORY ${SOURCE_PATH}
    )
message(STATUS "Configure ${TARGET_TRIPLET}-dbg done")

message(STATUS "Build ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND make libpython3.6m.a
    WORKING_DIRECTORY ${SOURCE_PATH}
    )
message(STATUS "Build ${TARGET_TRIPLET}-dbg done")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0003-Fix-header-for-static-linkage.patch
    )
endif()

file(GLOB HEADERS ${SOURCE_PATH}/Include/*.h)
if(WIN32)
file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})
else()
file(COPY ${HEADERS} ${SOURCE_PATH}/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})
endif()

file(COPY ${SOURCE_PATH}/Lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})

if(WIN32)
file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
else()
file(COPY ${SOURCE_PATH}/libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}m.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/copyright)

vcpkg_copy_pdbs()

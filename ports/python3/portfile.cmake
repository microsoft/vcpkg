if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(PYTHON_VERSION_MAJOR  3)
set(PYTHON_VERSION_MINOR  6)
set(PYTHON_VERSION_PATCH  4)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET})
vcpkg_from_github(
    OUT_SOURCE_PATH TEMP_SOURCE_PATH
    REPO python/cpython
    REF v${PYTHON_VERSION}
    SHA512 32cca5e344ee66f08712ab5533e5518f724f978ec98d985f7612d0bd8d7f5cac25625363c9eead192faf1806d4ea3393515f72ba962a2a0bed26261e56d8c637 
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${TEMP_SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0004-Fix-iomodule-for-RS4-SDK.patch
)

# We need per-triplet directories because we need to patch the project files differently based on the linkage
# Because the patches patch the same file, they have to be applied in the correct order
file(COPY ${TEMP_SOURCE_PATH} DESTINATION ${SOURCE_PATH})
set(SOURCE_PATH ${SOURCE_PATH}/cpython-${PYTHON_VERSION})

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

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(BUILD_ARCH "Win32")
    set(OUT_DIR "win32")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(BUILD_ARCH "x64")
    set(OUT_DIR "amd64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/PCBuild/pythoncore.vcxproj
    PLATFORM ${BUILD_ARCH})

if ("executable" IN_LIST FEATURES)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/PCBuild/python.vcxproj
        PLATFORM ${BUILD_ARCH})
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/PCBuild/pythonw.vcxproj
        PLATFORM ${BUILD_ARCH})
endif()

set(BUILD_MODULE OFF)
macro(add_python_module MNAME)
    set(BUILD_MODULE ON)
    if ("${MNAME}" IN_LIST FEATURES)
        vcpkg_build_msbuild(
            PROJECT_PATH ${SOURCE_PATH}/PCBuild/${MNAME}.vcxproj
            PLATFORM ${BUILD_ARCH})
    endif()
endmacro()

add_python_module(_ctypes)
add_python_module(_socket)
add_python_module(pyexpat)
add_python_module(select)
add_python_module(unicodedata)
add_python_module(winsound)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0003-Fix-header-for-static-linkage.patch
    )
endif()

file(GLOB HEADERS ${SOURCE_PATH}/Include/*.h)
file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})

file(GLOB LIBS ${SOURCE_PATH}/PCBuild/${OUT_DIR}/*.lib)
file(GLOB DEBUG_LIBS ${SOURCE_PATH}/PCBuild/${OUT_DIR}/*_d.lib)
list(REMOVE_ITEM LIBS ${DEBUG_LIBS})
file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# only python3 is supported in vcpkg right now, so the directory doesn't split python2 and python3
# setup python directories
file(COPY ${SOURCE_PATH}/Lib DESTINATION ${CURRENT_PACKAGES_DIR}/python)
file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/python/include)
file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/python/libs)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

if ("executable" IN_LIST FEATURES)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python.exe DESTINATION ${CURRENT_PACKAGES_DIR}/python)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/pythonw.exe DESTINATION ${CURRENT_PACKAGES_DIR}/python)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/python)
endif()

if (BUILD_MODULE)
    file(GLOB PYDS ${SOURCE_PATH}/PCBuild/${OUT_DIR}/*.pyd)
    file(GLOB DEBUG_PYDS ${SOURCE_PATH}/PCBuild/${OUT_DIR}/*_d.pyd)
    list(REMOVE_ITEM PYDS ${DEBUG_PYDS})
    file(COPY ${PYDS} DESTINATION ${CURRENT_PACKAGES_DIR}/python/DLLs)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/copyright)

vcpkg_copy_pdbs()

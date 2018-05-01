
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 01org/tbb
    REF 633b01ad27e012e1dc4e392c3230250d1f4967a4
    SHA512 5576b5e1efa0c7938dc08a1a9503ea19234b20f6a742f3d13a8de19b47f5bdafa1bb855e4de022a4b096a429e66739599a198fdf687c167c659f7556235fa01f
    HEAD_REF tbb_2018)

if(VCPKG_CMAKE_SYSTEM_NAME)
    # Linux. Using GNU make to build.
    # TODO: Darwin
    include(ProcessorCount)
    ProcessorCount(JCOUNT)

    foreach(CONF release debug)
        message(STATUS "Building ${CONF} with GNU make with ${JCOUNT} threads")

        vcpkg_execute_required_process(
            COMMAND
                make
                -C src
                tbb_${CONF}
                tbbmalloc_${CONF}
                compiler=gcc
                -j ${JCOUNT}
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME make-${CONF})
    endforeach()

    set(TBB_MSBUILD_PROJECT_DIR ${SOURCE_PATH}/build)

    file(GLOB DEBUG_OUTPUT_PATH ${TBB_MSBUILD_PROJECT_DIR}/*_debug)
    file(GLOB RELEASE_OUTPUT_PATH ${TBB_MSBUILD_PROJECT_DIR}/*_release)
else()
    # Windows. Using msbuild.
    message(STATUS "Building with msbuild")

    if (VCPKG_CRT_LINKAGE STREQUAL static)
        set(RELEASE_CONFIGURATION Release-MT)
        set(DEBUG_CONFIGURATION Debug-MT)
    else()
        set(RELEASE_CONFIGURATION Release)
        set(DEBUG_CONFIGURATION Debug)
    endif()

    set(TBB_MSBUILD_PROJECT_DIR ${SOURCE_PATH}/build/vs2013)

    if(TRIPLET_SYSTEM_ARCH STREQUAL x86)
        set(BUILD_ARCH Win32)
    else()
        set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
    endif()

    vcpkg_build_msbuild(
        PROJECT_PATH ${TBB_MSBUILD_PROJECT_DIR}/makefile.sln
        RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}
        DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
        PLATFORM ${BUILD_ARCH})

    set(DEBUG_OUTPUT_PATH ${TBB_MSBUILD_PROJECT_DIR}/${BUILD_ARCH}/${DEBUG_CONFIGURATION})
    set(RELEASE_OUTPUT_PATH ${TBB_MSBUILD_PROJECT_DIR}/${BUILD_ARCH}/${RELEASE_CONFIGURATION})
endif()

# Install the headers
message(STATUS "Installing")
file(COPY
  ${SOURCE_PATH}/include/tbb
  ${SOURCE_PATH}/include/serial
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(MAKE_DIRECTORY ${SOURCE_PATH}/static)
    file(
        COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
        DESTINATION ${SOURCE_PATH}/static)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}/static
        OPTIONS -DBUILD_ARCH=${TRIPLET_SYSTEM_ARCH}
        OPTIONS_RELEASE -DCONFIGURATION=${RELEASE_CONFIGURATION}
        OPTIONS_DEBUG -DCONFIGURATION=${DEBUG_CONFIGURATION} -DSUFFIX=_debug)

    vcpkg_install_cmake()
else()
    if(VCPKG_CMAKE_SYSTEM_NAME)
        # Linux.
        # TODO: Darwin
        set(LIB_MASKS *.so *.so.*)
    else()
        # Windows
        set(LIB_MASKS *.lib)

        # Copy DLLs
        file(GLOB DLLS_RELEASE ${RELEASE_OUTPUT_PATH}/*.dll)
        if(DLLS_RELEASE)
            file(COPY
                ${DLLS_RELEASE}
                DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        endif()

        file(GLOB DLLS_DEBUG ${DEBUG_OUTPUT_PATH}/*.dll)
        if(DLLS_DEBUG)
            file(COPY
                ${DLLS_DEBUG}
                DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        endif()

        vcpkg_copy_pdbs()
    endif()

    # Copy libraries
    foreach(LIB_MASK ${LIB_MASKS})
        file(GLOB LIBS_RELEASE ${RELEASE_OUTPUT_PATH}/${LIB_MASK})
        if(LIBS_RELEASE)
            file(COPY
                ${LIBS_RELEASE}
                DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        endif()

        file(GLOB LIBS_DEBUG ${DEBUG_OUTPUT_PATH}/${LIB_MASK})
        if(LIBS_DEBUG)
            file(COPY
                ${LIBS_DEBUG}
                DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
        endif()
    endforeach()
endif()

include(${SOURCE_PATH}/cmake/TBBMakeConfig.cmake)
tbb_make_config(TBB_ROOT ${CURRENT_PACKAGES_DIR}
    CONFIG_DIR TBB_CONFIG_DIR # is set to ${CURRENT_PACKAGES_DIR}/cmake
    SYSTEM_NAME "Windows"
    CONFIG_FOR_SOURCE
    TBB_RELEASE_DIR "\${_tbb_root}/bin"
    TBB_DEBUG_DIR "\${_tbb_root}/debug/bin")

file(COPY ${TBB_CONFIG_DIR}/TBBConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(COPY ${TBB_CONFIG_DIR}/TBBConfigVersion.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(REMOVE_RECURSE ${TBB_CONFIG_DIR})

# make it work with our installation layout
file(READ ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake TBB_CONFIG_CMAKE)
string(REPLACE
"get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)"
"get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)
get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)" TBB_CONFIG_CMAKE "${TBB_CONFIG_CMAKE}")
string(REPLACE
"\${_tbb_root}/bin/\${_tbb_component}.lib"
"\${_tbb_root}/lib/\${_tbb_component}.lib" TBB_CONFIG_CMAKE "${TBB_CONFIG_CMAKE}")
string(REPLACE
"\${_tbb_root}/debug/bin/\${_tbb_component}_debug.lib"
"\${_tbb_root}/debug/lib/\${_tbb_component}_debug.lib" TBB_CONFIG_CMAKE "${TBB_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake "${TBB_CONFIG_CMAKE}")

message(STATUS "Installing done")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tbb/LICENSE ${CURRENT_PACKAGES_DIR}/share/tbb/copyright)

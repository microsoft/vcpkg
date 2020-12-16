vcpkg_fail_port_install(ON_TARGET MINGW)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIAGameWorks/PhysX
    REF ae80dede0546d652040ae6260a810e53e20a06fa
    SHA512 f3a690039cf39fe2db9a728b82af0d39eaa02340a853bdad4b5152d63532367eb24fc7033a614882168049b80d803b6225fc60ed2900a9d0deab847f220540be
    HEAD_REF master
    PATCHES
        internalMBP_symbols.patch
        msvc_142_bug_workaround.patch
        vs16_3_typeinfo_header_fix.patch
        fix_discarded_qualifiers.patch
)

if(NOT DEFINED RELEASE_CONFIGURATION)
    set(RELEASE_CONFIGURATION "release")
endif()
set(DEBUG_CONFIGURATION "debug")

set(OPTIONS
    "-DPHYSX_ROOT_DIR=${SOURCE_PATH}/physx"
    "-DPXSHARED_PATH=${SOURCE_PATH}/pxshared"
    "-DPXSHARED_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
    "-DCMAKEMODULES_PATH=${SOURCE_PATH}/externals/cmakemodules"
    "-DCMAKEMODULES_NAME=CMakeModules"
    "-DCMAKE_MODULES_VERSION=1.27"
    "-DPX_BUILDSNIPPETS=OFF"
    "-DPX_BUILDPUBLICSAMPLES=OFF"
    "-DPX_FLOAT_POINT_PRECISE_MATH=OFF"
    "-DPX_COPY_EXTERNAL_DLL=OFF"
    "-DGPU_DLL_COPIED=ON"
)

set(OPTIONS_RELEASE
    "-DPX_OUTPUT_BIN_DIR=${CURRENT_PACKAGES_DIR}"
    "-DPX_OUTPUT_LIB_DIR=${CURRENT_PACKAGES_DIR}"
)
set(OPTIONS_DEBUG
    "-DPX_OUTPUT_BIN_DIR=${CURRENT_PACKAGES_DIR}/debug"
    "-DPX_OUTPUT_LIB_DIR=${CURRENT_PACKAGES_DIR}/debug"
    "-DNV_USE_DEBUG_WINCRT=ON"
)

if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=uwp")
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=windows")
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=mac")
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_FREEBSD)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=linux")
elseif(VCPKG_TARGET_IS_ANDROID)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=android")
else()
    message(FATAL_ERROR "Unhandled or unsupported target platform.")
endif()

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    list(APPEND OPTIONS "-DNV_FORCE_64BIT_SUFFIX=ON" "-DNV_FORCE_32BIT_SUFFIX=OFF")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "-DPX_GENERATE_STATIC_LIBRARIES=OFF")
else()
    list(APPEND OPTIONS "-DPX_GENERATE_STATIC_LIBRARIES=ON")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "-DNV_USE_STATIC_WINCRT=OFF")
else()
    list(APPEND OPTIONS "-DNV_USE_STATIC_WINCRT=ON")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND OPTIONS "-DPX_OUTPUT_ARCH=arm")
else()
    list(APPEND OPTIONS "-DPX_OUTPUT_ARCH=x86")
endif()

# Replicate PhysX's CXX Flags here so we don't have to patch out /WX and -Wall
list(APPEND OPTIONS "-DPHYSX_CXX_FLAGS:INTERNAL=${VCPKG_CXX_FLAGS}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/physx/compiler/public"
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
)
vcpkg_install_cmake()

# NVIDIA Gameworks release structure is generally something like <compiler>/<configuration>/[artifact]
# It would be nice to patch this out, but that directory structure is hardcoded over many cmake files.
# So, we have this helpful helper to copy the bins and libs out.
function(fixup_physx_artifacts)
    macro(_fixup _IN_DIRECTORY _OUT_DIRECTORY)
        foreach(_SUFFIX IN LISTS _fpa_SUFFIXES)
            file(GLOB_RECURSE _ARTIFACTS
                LIST_DIRECTORIES false
                "${CURRENT_PACKAGES_DIR}/${_IN_DIRECTORY}/*${_SUFFIX}"
            )
            if(_ARTIFACTS)
                file(COPY ${_ARTIFACTS} DESTINATION "${CURRENT_PACKAGES_DIR}/${_OUT_DIRECTORY}")
            endif()
        endforeach()
    endmacro()

    cmake_parse_arguments(_fpa "" "DIRECTORY" "SUFFIXES" ${ARGN})
    _fixup("bin" ${_fpa_DIRECTORY})
    _fixup("debug/bin" "debug/${_fpa_DIRECTORY}")
endfunction()

fixup_physx_artifacts(
    DIRECTORY "lib"
    SUFFIXES ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}
)
fixup_physx_artifacts(
    DIRECTORY "bin"
    SUFFIXES ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX} ".pdb"
)

# Remove compiler directory and descendents.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin/"
        "${CURRENT_PACKAGES_DIR}/debug/bin/"
    )
else()
    file(GLOB PHYSX_ARTIFACTS LIST_DIRECTORIES true
        "${CURRENT_PACKAGES_DIR}/bin/*"
        "${CURRENT_PACKAGES_DIR}/debug/bin/*"
    )
    foreach(_ARTIFACT IN LISTS PHYSX_ARTIFACTS)
        if(IS_DIRECTORY ${_ARTIFACT})
            file(REMOVE_RECURSE ${_ARTIFACT})
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/source"
    "${CURRENT_PACKAGES_DIR}/source"
)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

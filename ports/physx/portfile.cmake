vcpkg_download_distfile(
    patch1
    URLS "https://github.com/NVIDIAGameWorks/PhysX/commit/ada4fccf04e5a5832af1353d6d1f91de691aa47d.patch"
    FILENAME "physx-PR569-ada4fccf.patch"
    SHA512 ec2fc2fce0b5aab4d42b77f21373bf067f129543e672516477513419241c56b99f2d663b992cb29d296933440e7e7cc31a57198f6fcc78d6eac26b7706c1e937
)

vcpkg_download_distfile(
    patch2
    URLS "https://github.com/NVIDIAGameWorks/PhysX/commit/d590c88e3cbf0fb682726abf7d7c16417855084f.patch"
    FILENAME "physx-PR569-d590c88e.patch"
    SHA512 4eb7630db1cb10b2372220c3706dfe255075f466c6b2b12654c9fbc3b17c4df69d7b91e6f0d798c92a4cb8806e1c34b66bb52b46d9358d643ca62ec0de321fd2
)

vcpkg_download_distfile(
    patch3
    URLS "https://github.com/NVIDIAGameWorks/PhysX/commit/cdbfc0f1283829c71b07e332ddd6ce2e5aa7d467.patch"
    FILENAME "physx-PR569-cdbfc0f.patch"
    SHA512 2d9d4d30d923b0e006ae1a5c413993325bb4ce5c130fe655242611e87dab945cb220776f112b6cf96b1f06c83a6cec475314a11649bf03304083f5068e282ef2
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIAGameWorks/PhysX
    REF 93c6dd21b545605185f2febc8eeacebe49a99479
    SHA512 c9f50255ca9e0f1ebdb9926992315a62b77e2eea3addd4e65217283490714e71e24f2f687717dd8eb155078a1a6b25c9fadc123ce8bc4c5615f7ac66cd6b11aa
    HEAD_REF master
    PATCHES
        fix-compiler-flag.patch
        "${patch1}"
        "${patch2}"
        "${patch3}"
        remove-werror.patch
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
    set(configure_options WINDOWS_USE_MSBUILD)
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/physx/compiler/public"
    ${configure_options}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
)
vcpkg_cmake_install()

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
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

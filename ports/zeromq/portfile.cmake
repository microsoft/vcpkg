set(ZEROMQ_VERSION 4.2.2)
set(ZEROMQ_HASH 4069813374d4e8d4c0f8debbe85472d0bd24cf644fb1bce748920eadffb81c429d28f523ef424df84fcaa7082b984fab8da57192802585811d37cff066f4e40c)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libzmq-${ZEROMQ_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/zeromq/libzmq/archive/v${ZEROMQ_VERSION}.tar.gz"
    FILENAME "libzmq-${ZEROMQ_VERSION}.tar.gz"
    SHA512 ${ZEROMQ_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

# Map from triplet "x86" to "win32" as used in the vcxproj file.
if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

if(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
  set(MSVS_VERSION 2017)
else()
  set(MSVS_VERSION 2015)
endif()

if(DEFINED VCPKG_TRIPLET_PLATFORM_TOOLSET)
  set(ZEROMQ_TOOLSET ${VCPKG_TRIPLET_PLATFORM_TOOLSET})
else()
  set(ZEROMQ_TOOLSET ${VCPKG_PLATFORM_TOOLSET})
endif()

if(DEFINED VCPKG_TRIPLET_PLATFORM_TOOLSET_SUFFIX)
  string(CONCAT ZEROMQ_TOOLSET "${ZEROMQ_TOOLSET}" "_" "${VCPKG_TRIPLET_PLATFORM_TOOLSET_SUFFIX}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/builds/msvc/vs${MSVS_VERSION}/libzmq/libzmq.vcxproj
        RELEASE_CONFIGURATION ReleaseDLL
        DEBUG_CONFIGURATION DebugDLL
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Debug/${ZEROMQ_TOOLSET}/dynamic/libzmq.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Release/${ZEROMQ_TOOLSET}/dynamic/libzmq.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Debug/${ZEROMQ_TOOLSET}/dynamic/libzmq.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Release/${ZEROMQ_TOOLSET}/dynamic/libzmq.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
    vcpkg_copy_pdbs()

else()
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/builds/msvc/vs${MSVS_VERSION}/libzmq/libzmq.vcxproj
        RELEASE_CONFIGURATION ReleaseLIB
        DEBUG_CONFIGURATION DebugLIB
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Debug/${ZEROMQ_TOOLSET}/static/libzmq.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Release/${ZEROMQ_TOOLSET}/static/libzmq.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
endif()


file(INSTALL
    ${SOURCE_PATH}/include/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/zeromq)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zeromq/COPYING ${CURRENT_PACKAGES_DIR}/share/zeromq/copyright)


include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zeromq-4.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/zeromq/libzmq/releases/download/v4.2.0/zeromq-4.2.0.tar.gz"
    FILENAME "zeromq-4.2.0.tar.gz"
    SHA512 3b6f0a1869fb1663ea40b3c3aa088b81399a35c051e4ade2b30bbac60bfceefe6b4403248a4635fb31d33767c1e478342f61c47b0ffdb4501419c13590ebeb96
)
vcpkg_extract_source_archive(${ARCHIVE})

# Map from triplet "x86" to "win32" as used in the vcxproj file.
if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/builds/msvc/vs2015/libzmq/libzmq.vcxproj
        RELEASE_CONFIGURATION ReleaseDLL
        DEBUG_CONFIGURATION DebugDLL
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Debug/v140/dynamic/libzmq.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Release/v140/dynamic/libzmq.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Debug/v140/dynamic/libzmq.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Release/v140/dynamic/libzmq.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
    vcpkg_copy_pdbs()

else()
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/builds/msvc/vs2015/libzmq/libzmq.vcxproj
        RELEASE_CONFIGURATION ReleaseLIB
        DEBUG_CONFIGURATION DebugLIB
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Debug/v140/static/libzmq.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}/Release/v140/static/libzmq.lib
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


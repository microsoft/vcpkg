vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrogier/ocilib
    REF 46ea6532e9ae0cf43ecc11dc2ca6542238b3d34d      #v4.7.0
    SHA512 35fc78ab807666f4c3713d2b2f1fb8c75391b33eca0d576c35f832a17492e5b9df2b71bebbf2ebc348259de3f5d7954b039f211aa5d01f91385943d1cdafc917
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(SOLUTION_TYPE vs2019)
    set(OCILIB_ARCH_X86 x86)
    set(OCILIB_ARCH_X64 x64)
    
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(PLATFORM ${OCILIB_ARCH_X86})
    else()
        set(PLATFORM ${OCILIB_ARCH_X64})
    endif()
    
    # There is no debug configuration
    # As it is a C library, build the release configuration and copy its output to the debug folder
    set(VCPKG_BUILD_TYPE release)
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH proj/dll/ocilib_dll_${SOLUTION_TYPE}.sln
        INCLUDES_SUBPATH include
        LICENSE_SUBPATH LICENSE
        RELEASE_CONFIGURATION "Release - ANSI"
        PLATFORM ${PLATFORM}
        USE_VCPKG_INTEGRATION
        ALLOW_ROOT_INCLUDES)

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
else()
    vcpkg_configure_make(
        COPY_SOURCE
        AUTOCONFIG
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS 
            --with-oracle-import=runtime
    )

    vcpkg_install_make()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/doc/${PORT} ${CURRENT_PACKAGES_DIR}/share/${PORT})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
    file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()

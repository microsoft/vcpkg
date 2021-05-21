vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hunspell/hunspell
    REF v1.7.0
    SHA512 8149b2e8b703a0610c9ca5160c2dfad3cf3b85b16b3f0f5cfcb7ebb802473b2d499e8e2d0a637a97a37a24d62424e82d3880809210d3f043fa17a4970d47c903
    HEAD_REF master
    PATCHES 
        0001_fix_unistd.patch
        fix-static-build.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(REMOVE "${SOURCE_PATH}/README") #README is a symlink
    if(NOT "tools" IN_LIST FEATURES)
        vcpkg_install_msbuild(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "msvc/libhunspell.vcxproj"
            INCLUDES_SUBPATH src/hunspell
            USE_VCPKG_INTEGRATION
            ALLOW_ROOT_INCLUDES      
        )
    else()
        vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "msvc/hunspell.vcxproj"
        INCLUDES_SUBPATH src/hunspell
        USE_VCPKG_INTEGRATION
        ALLOW_ROOT_INCLUDES      
    )
    endif()
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(ENV{CFLAGS} "$ENV{CFLAGS} -DHUNSPELL_STATIC")
        set(ENV{CXXFLAGS} "$ENV{CXXFLAGS} -DHUNSPELL_STATIC")
    endif()
    if(NOT "tools" IN_LIST FEATURES) # Building the tools is not possible on windows!
        file(READ "${SOURCE_PATH}/src/Makefile.am" _contents)
        string(REPLACE " parsers tools" "" _contents "${_contents}")
        file(WRITE "${SOURCE_PATH}/src/Makefile.am" "${_contents}")
    endif()
    vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS 
        AUTOCONFIG
        ADDITIONAL_MSYS_PACKAGES gzip
    )
    #install-pkgconfDATA:
    vcpkg_build_make(BUILD_TARGET dist LOGFILE_ROOT build-dist)
    vcpkg_install_make()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    vcpkg_fixup_pkgconfig()
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/COPYING.LESSER" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright-lgpl)
file(INSTALL "${SOURCE_PATH}/COPYING.MPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright-mpl)

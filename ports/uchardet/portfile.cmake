vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://gitlab.freedesktop.org/uchardet/uchardet
    REF bdfd6116a965fd210ef563613763e724424728b7
    PATCHES
        fix-string-no-output-variable.patch
        fix-tool-build-error.patch
        win32-getopt.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    # On Windows, we can get a uchardet.dll, but it exports no symbols.
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tool BUILD_BINARY
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DBUILD_BINARY=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS
        -DBUILD_STATIC=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(tool IN_LIST FEATURES)
    file(COPY
        ${CURRENT_PACKAGES_DIR}/bin/uchardet${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
    )

    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/uchardet${VCPKG_TARGET_EXECUTABLE_SUFFIX})
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/man
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

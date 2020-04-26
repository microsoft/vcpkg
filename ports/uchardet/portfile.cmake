vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://gitlab.freedesktop.org/uchardet/uchardet
    REF 8681fc060ea07f646434cd2d324e4a5aa7c495c4
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tool BUILD_BINARY
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DBUILD_BINARY=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS
        -DBUILD_STATIC=${BUILD_STATIC}
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

cpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathisloge/comms_champion
    REF v3.1.1
    SHA512 167838aec1d42ce60e373aaa1c3b3f0093735e54b80c12229624fa5617b713462609b46585dbe9a1637404e88bd051eda2e619d21bff60056693e79dd9e53878
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS INVERTED_FEATURES
    champion    CC_COMMS_LIB_ONLY
    tools       CC_LIBS_ONLY
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCC_NO_UNIT_TESTS=ON
)
vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/CommsChampion/plugin")

file(INSTALL "${CURRENT_PACKAGES_DIR}/lib/CommsChampion/plugin" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/CommsChampion/plugin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/CommsChampion/plugin")
if(WIN32)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/cc_dump.bat" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/cc_view.bat" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if(NOT CC_LIBS_ONLY)
    set(TOOL_NAMES cc_dump cc_view)
    vcpkg_copy_pdbs()
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
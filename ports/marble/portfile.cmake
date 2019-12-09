vcpkg_fail_port_install(ON_TARGET "LINUX" "OSX" ON_LIBRARY_LINKAGE "static")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/marble
    REF a7b7e23113a8a87ae2206caed969ab557137c282 #v19.08.2
    SHA512 f808bfbb118f509bd7939e8ae514a72cb9eec30b3a42f2bfedffcbeab7a1cbd658e35b5cd3e90ebeeacee6402c11ae9d293c12aaa5f2d70908e451b174a58e8e
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_MARBLE_TOOLS
        tests BUILD_MARBLE_TESTS
        plugins WITH_DESIGNER_PLUGIN
)
 
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

# Install  plugins
file(GLOB  EXE "${CURRENT_PACKAGES_DIR}/*.exe")
file(GLOB  DLL "${CURRENT_PACKAGES_DIR}/*.dll")
file(GLOB_RECURSE  PLUGINS "${CURRENT_PACKAGES_DIR}/plugins/*")
file(GLOB_RECURSE  DATA "${CURRENT_PACKAGES_DIR}/data/*")
file(GLOB_RECURSE  MKSPECS "${CURRENT_PACKAGES_DIR}/mkspecs/*")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${DLL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${PLUGINS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/plugins)
file(COPY ${DATA} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/data)
file(COPY ${MKSPECS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/mkspecs)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

 # remove plugin folder
file(GLOB  DEXE "${CURRENT_PACKAGES_DIR}/debug/*.exe")
file(GLOB  DDLL "${CURRENT_PACKAGES_DIR}/debug/*.dll")

file(REMOVE_RECURSE
    ${EXE} ${DEXE} ${DLL} ${DDLL}
    ${CURRENT_PACKAGES_DIR}/plugins ${CURRENT_PACKAGES_DIR}/debug/plugins
    ${CURRENT_PACKAGES_DIR}/data    ${CURRENT_PACKAGES_DIR}/debug/data
    ${CURRENT_PACKAGES_DIR}/mkspecs ${CURRENT_PACKAGES_DIR}/debug/mkspecs
    ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

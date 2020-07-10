vcpkg_fail_port_install(ON_TARGET "LINUX" "OSX" "UWP" "ANDROID" ON_ARCH "arm" "x86" ON_LIBRARY_LINKAGE "static")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/marble
    REF a7b7e23113a8a87ae2206caed969ab557137c282 #v19.08.2
    SHA512 f808bfbb118f509bd7939e8ae514a72cb9eec30b3a42f2bfedffcbeab7a1cbd658e35b5cd3e90ebeeacee6402c11ae9d293c12aaa5f2d70908e451b174a58e8e
    HEAD_REF master
    PATCHES "move-exe-to-tools.patch"
)
 
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

# Install  plugins and data files
file(GLOB_RECURSE  PLUGINS "${CURRENT_PACKAGES_DIR}/plugins/*")
file(GLOB_RECURSE  PLUGINS_DESIGNER "${CURRENT_PACKAGES_DIR}/lib/plugins/*")
file(GLOB_RECURSE  PLUGINS_DEBUG "${CURRENT_PACKAGES_DIR}/debug/lib/plugins/*")
file(GLOB_RECURSE  MKSPECS "${CURRENT_PACKAGES_DIR}/mkspecs/*")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${PLUGINS} ${PLUGINS_DESIGNER} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/plugins)
file(COPY ${PLUGINS_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/plugins)
file(COPY "${CURRENT_PACKAGES_DIR}/data" DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}) # have to keep folder structure here
file(COPY ${MKSPECS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/mkspecs)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# remove plugin folder
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/plugins ${CURRENT_PACKAGES_DIR}/debug/plugins
    ${CURRENT_PACKAGES_DIR}/data    ${CURRENT_PACKAGES_DIR}/debug/data
    ${CURRENT_PACKAGES_DIR}/mkspecs ${CURRENT_PACKAGES_DIR}/debug/mkspecs
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/lib/plugins   ${CURRENT_PACKAGES_DIR}/lib/plugins
)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

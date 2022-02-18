
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/marble
    REF 552cb9ae1f34482d1ec56532a703e0d820856286 #v20.04.3
    SHA512 ac6106a6db53534c96d7281b1a07624c2852ed8c78cce0b91c5f865b106487f1f49aaa4c72d00ffb1f79a761d8d2eca18129ef9517bef463a1840554ed3e51fb
    HEAD_REF master
    PATCHES "qtfix.patch"
)
 
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_I18n=ON
        -DWITH_KF5=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

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

# remove plugin folder
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/plugins ${CURRENT_PACKAGES_DIR}/debug/plugins
    ${CURRENT_PACKAGES_DIR}/data    ${CURRENT_PACKAGES_DIR}/debug/data
	${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/mkspecs ${CURRENT_PACKAGES_DIR}/debug/mkspecs
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/lib/plugins   ${CURRENT_PACKAGES_DIR}/lib/plugins
)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

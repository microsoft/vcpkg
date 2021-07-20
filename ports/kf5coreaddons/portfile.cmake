vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcoreaddons
    REF v5.81.0
    SHA512 438b2a6fbb040e9442bdfd7f29388165ed8df3bbb676d93efd86ccaa2106c9b5d3b9561eecb10fb14f54d46dac8f0c969c424ec9e351e18ee2c742de418596b9
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS 
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_DATAROOTDIR=data
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5CoreAddons)
vcpkg_copy_pdbs()

vcpkg_copy_tools( 
    TOOL_NAMES desktoptojson
    AUTO_CLEAN
)

file(APPEND ${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf "Data = ../../data")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/desktoptojson${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kwindowsystem
    REF v5.84.0
    SHA512 53491f8576db8ebb48627e098fd8c3d4029c024bb9048d97daa1a8f5c39e594ca05dcd80ecb18ac591af7455457a0f14459c24cf44487727a26e34f977c5b81a
)

if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libxcb-res0-dev\n\nThese can be installed on Ubuntu systems via apt-get install libxcb-res0-dev")
endif()

vcpkg_configure_cmake(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
    MAYBE_UNUSED_VARIABLES
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5WindowSystem)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

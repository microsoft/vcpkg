vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF v5.3.2
    SHA512 ee42e90e1e9410c5ffa6d8d4bbf76c1ae11d25619a24890623976c0a911ab05db6c25ac821b3d1ecd4e1da52f0a95ef5ab39e52f1099ed655298eb8ec85e636a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qt WITH_CGAL_Qt5
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCGAL_HEADER_ONLY=ON
        -DCGAL_INSTALL_CMAKE_DIR=share/cgal
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
else()
    foreach(ROOT ${CURRENT_PACKAGES_DIR}/bin)
        file(REMOVE
            ${ROOT}/cgal_create_CMakeLists
            ${ROOT}/cgal_create_cmake_script
            ${ROOT}/cgal_make_macosx_app
        )
    endforeach()
endif()

file(INSTALL ${SOURCE_PATH}/Installation/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(
    COPY
        ${SOURCE_PATH}/Installation/LICENSE.BSL
        ${SOURCE_PATH}/Installation/LICENSE.RFL
        ${SOURCE_PATH}/Installation/LICENSE.GPL
        ${SOURCE_PATH}/Installation/LICENSE.LGPL
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

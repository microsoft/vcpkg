vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF v5.4
    SHA512 c9cdacc74844a6eca94980d0350ae6defb99462ef70ddc3e15e825f06b171a21571efd9246a4abac16a6efc350aa9fa79330d2e89dcec24fc6ecff51905efdeb
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

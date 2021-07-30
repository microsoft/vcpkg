vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF v5.3
    SHA512 b4093b5f1b4802cffe5dd6a47a7382a59ed83d30bb8cafa5f3fa8daef4579c9f3caf208bc2a58b7a41cf61ed825d0e549c7c442e9f5977bd82f553b2dfe8748f
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qt WITH_CGAL_Qt5
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCGAL_HEADER_ONLY=ON
        -DCGAL_INSTALL_CMAKE_DIR=share/cgal
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

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

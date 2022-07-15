# Header only
vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF v5.4.1
    SHA512 2ec6167d8ebf1df121f1ac372d01862f7f3acb043deea4a334e0329976306f9c9e917cdc66b355728d3f99fdb76f5491d96f10fff660716ce27bfd3793380875
    HEAD_REF master
    PATCHES fix-incorrect-warning.patch # https://github.com/CGAL/cgal/pull/6649
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
        -DBUILD_TESTING=OFF
        -DBUILD_DOC=OFF
        -DCGAL_BUILD_THREE_DOC=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CGAL_BUILD_THREE_DOC
        CGAL_HEADER_ONLY
        WITH_CGAL_Qt5
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
else()
    foreach(ROOT "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE
            "${ROOT}/cgal_create_CMakeLists"
            "${ROOT}/cgal_create_cmake_script"
            "${ROOT}/cgal_make_macosx_app"
        )
    endforeach()
endif()

file(INSTALL "${SOURCE_PATH}/Installation/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(
    COPY
        "${SOURCE_PATH}/Installation/LICENSE.BSL"
        "${SOURCE_PATH}/Installation/LICENSE.RFL"
        "${SOURCE_PATH}/Installation/LICENSE.GPL"
        "${SOURCE_PATH}/Installation/LICENSE.LGPL"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

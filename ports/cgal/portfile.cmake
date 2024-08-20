# Header only
vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF v5.6.1
    SHA512 943413bf3b94da066d47051b22f1c1b66a39a43dad865dd0e4912a9ae6508d9a490bcfe4ef7d662844e9a1ba6e552748fad785b52b2cce98133c2dfdfbfe1a4d
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/share/man")

set(LICENSES
    "${SOURCE_PATH}/Installation/LICENSE"
        "${SOURCE_PATH}/Installation/LICENSE.BSL"
        "${SOURCE_PATH}/Installation/LICENSE.RFL"
        "${SOURCE_PATH}/Installation/LICENSE.GPL"
        "${SOURCE_PATH}/Installation/LICENSE.LGPL"
)

vcpkg_install_copyright(FILE_LIST ${LICENSES})

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

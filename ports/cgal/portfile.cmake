set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF v${VERSION}
    SHA512 682a028aee951b631827ede9a2fe7cacebbefdf0b2cc63c25c43828eb1f749800e995079c1655b820db41157e03c9cc4286d68d66b9bb7e97a7522f6d0fae05f
    HEAD_REF master
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

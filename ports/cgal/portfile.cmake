set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF "v${VERSION}"
    SHA512 6c94b58302454315ad5abce08484d93d38d7772e44d28051ec2188bdbc88852c45ff67ccdcd214d8872d2df92e47751d658f96a4d5b8c0ed167be8e6165ef667
    HEAD_REF main
    PATCHES
        progbits.patch # https://github.com/CGAL/cgal/pull/9634
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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/Installation/LICENSE"
        "${SOURCE_PATH}/Installation/LICENSE.BSL"
        "${SOURCE_PATH}/Installation/LICENSE.RFL"
        "${SOURCE_PATH}/Installation/LICENSE.GPL"
        "${SOURCE_PATH}/Installation/LICENSE.LGPL"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Gecode/gecode
    REF 027c57889d66dd26ad8e1a419c2cda22ab0cf305
    SHA512 7db2d569415c6a42af141bf8dbc61775566bf90256ad9c3f875d6dfc51364d259cedf89571e487c70c01913031d9f01d566b02848598e3576448ab000ca2abc5
    HEAD_REF master
)

# string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" JSONCPP_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    # OPTIONS
)

vcpkg_install_cmake()

# vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gecode)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

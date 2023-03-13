# vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leadedge/Spout2
    REF 9db0efadba16e1d884164d348f556922cfc80c50 #v2.007.009
    SHA512 d45613590fb53155c90839cf6eb7fe646ef4ec463b6cd1624aff54870818f0bc4faccded78a6b2c089fa4e8756cf15c7e17def2ef32ac6c34144e562b58c5d8b
    HEAD_REF master
    PATCHES
        fixup_for_vcpkg.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND OPTIONS -DSPOUT_BUILD_CMT=ON)
else()
    list(APPEND OPTIONS -DSPOUT_BUILD_CMT=OFF)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx              SPOUT_BUILD_SPOUTDX
        c               SPOUT_BUILD_LIBRARY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSKIP_INSTALL_ALL=OFF
        ${FEATURE_OPTIONS}
        ${OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

# Handle copyright & usage
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# remove unneeded files
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

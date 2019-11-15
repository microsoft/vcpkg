vcpkg_fail_port_install(MESSAGE "${PORT} currently doesn't support uwp." ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vancegroup/freealut
    REF fc814e316c2bfa6e05b723b8cc9cb276da141aae
    SHA512 046990cc13822ca6eea0b8e412aa95a994b881429e0b15cefee379f08bd9636d4a4598292a8d46b30c3cd06814bfaeae3298e8ef4087a46eede344f3880e9fed
    HEAD_REF master
    PATCHES
        fix-build-error.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test BUILD_TESTS
    example BUILD_EXAMPLES
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC ON)
else()
    set(BUILD_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

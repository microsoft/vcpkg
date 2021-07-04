vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/draco
    REF 83b0922745981a35be16e2907bdbb749ebf2bf43 # 1.3.6
    SHA512 29b270d749c5c0efcf791aaae7e33e2ae4404103ad8849d73aaca71492a3780d2fcaec01ec225da886bce2ab20ec14b8cf2d9e0976810cdaee557f97b3b0d9b8
    HEAD_REF master
    PATCHES
        fix-compile-error-uwp.patch
        fix-uwperror.patch
        fix-build-error-in-gcc11.patch # Remove this patch in next release 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/draco/cmake)

# Install tools and plugins
file(GLOB TOOLS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.exe")
if(TOOLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/draco)
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/draco)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/draco)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/draco)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

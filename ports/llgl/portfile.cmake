include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LukasBanana/LLGL
    REF 8f28437960ed60622e94f4f97b24e842b5a0e9e6
    SHA512 8a6bd4109e977f9def0f04a3d31f7bd4beebbe162c52eaa08a54daf8335871615215ece166e5a9d5b5475b834fd53a26ff9638ff270a2f00c88bab21ed156760
    HEAD_REF master
    PATCHES fix-install-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
      ${FEATURE_OPTIONS} 
)

vcpkg_install_cmake()

# Move CMake files to the right place
#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

 if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
 endif()

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)


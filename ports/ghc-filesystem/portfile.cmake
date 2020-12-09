#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gulrak/filesystem
    REF v1.3.8
    SHA512 4ffda68ba2a6c6f79bf9384645dd99a25aca980b16cbf22d3700ba64839d2a68890777f02e2487afb4901cc3128449f9645f79f9531ddaf61f5f76859f015d9f
    HEAD_REF master
    )
        
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    -DGHC_FILESYSTEM_BUILD_TESTING=OFF
    -DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF
    -DGHC_FILESYSTEM_WITH_INSTALL=ON
    )

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ghc-filesystem)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ghc-filesystem/LICENSE ${CURRENT_PACKAGES_DIR}/share/ghc-filesystem/copyright)

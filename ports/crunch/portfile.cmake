vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rouault/crunch
    REF 079b071dfc24d309fb22fa41ccd94a0a156cdb52
    SHA512   486f1a3d25c777d93027579ded5f6838d3d056c020a9e4536cc669d78f999794ebab1fb311be575cc816e9918a9e8d4f4e7c80fea30329667401780ad7f96775
    HEAD_REF build_fixes
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Install tools and plugins
file(GLOB TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(TOOLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

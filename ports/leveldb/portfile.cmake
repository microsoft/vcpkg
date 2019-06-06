include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    BRANCH "bitcoin-fork"
    REPO "bitcoin-core/leveldb"
    REF "8b1cd3753b184341e837b30383832645135d3d73"
    SHA512  f5ad5fd21fb28ee052a4f3873abd58dab508c71621bcd482ab9e6ef4b57eca182c81502ddfe59736f5b2a54f2d05b397dd15982b3bd5d9039cd481eae3c7b958
)

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/msvc_code_fix.diff)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/leveldb RENAME copyright)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO godotengine/godot-cpp
    REF "godot-${VERSION}-stable"
    SHA512 "7fe4d02e409fa2c4c4476fb02c0cf6deb79bb1daa6aa370369587542283dc9d9d51fa6cd9604ac6b5cbd28e9ee5dd8844482c44c3d535f5e0190a7031feab68c"
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build(TARGET godot-cpp)

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/gdextension" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(GLOB DEBUG_LIBS 
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
)
file(INSTALL ${DEBUG_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

file(GLOB RELEASE_LIBS 
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
)
file(INSTALL ${RELEASE_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/usage")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
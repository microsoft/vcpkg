include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fredrik-johansson/arb
    REF fbc1c1a1630363b2905721fdc3598b5ed3b29b99
    SHA512 171c965aeb03cd2830df8a53990403c6da480a94d44385dadfbb2d02697f7c03e8b9a217094b0ad93f796d889a1564f4b9ae9db35ef9de90f61bb2e3220911be
    HEAD_REF master
)

file(REMOVE ${SOURCE_PATH}/CMakeLists.txt)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()


# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/arb RENAME copyright)

# Remove duplicate headers
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

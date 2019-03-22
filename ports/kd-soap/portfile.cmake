include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSoap
    REF 66a7804f157f51bc62c193b63a28918236bd7424
    SHA512 e9e2ac3ef714ebd5a85972c0eed613f88cc36f213df4fb938d61b58947972524f26f54a226f8e28ce47385cd859030a560781b4aebe3a25e672ac82b5477eeb8
    HEAD_REF master
)
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/8236bd7424-79789c62ed
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/kd-saop.patch"
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/kd-soap RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kdwsdl2cpp.exe ${CURRENT_PACKAGES_DIR}/tools/kdwsdl2cpp.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kdwsdl2cpp.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

include(vcpkg_common_functions)

if (VCPKG_TARGET_IS_UWP)
    message(FATAL_ERROR "Package `googleapis` doesn't support UWP")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/cpp-cmakefiles
    REF v0.1.3
    SHA512 5c6be5af731d97dcf754b1f643c35a1c806e6b976a3dd027dd80ee15f86c6d70f772dcecbf2da5597a4e8d8d9639813c2d2f66dd7112b8039c14c3a49ec6c4db
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/googleapis RENAME copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

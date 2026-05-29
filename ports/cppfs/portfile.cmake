vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/cppfs
    REF 156d72e2cf0a9b12bdce369fc5b5d98fb5dffe2d # v1.3.0
    SHA512 da1e09f79d9e65e7676784f47196645aabe1e1284f0ea5e48e845a244f5d49f5ea4b032f9e2e38c8e6a29657ebe636c9b1c9a4601c4bbc7637e7f592c52a8961
    HEAD_REF master
    PATCHES
        ssh-dependencies.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssh       OPTION_BUILD_SSH_BACKEND
        ssh       CMAKE_REQUIRE_FIND_PACKAGE_LibSSH2
        ssh       CMAKE_REQUIRE_FIND_PACKAGE_OpenSSL
        ssh       CMAKE_REQUIRE_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_cppcheck=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_clang_tidy=ON
        -DOPTION_BUILD_TESTS=OFF
        -DOPTION_FORCE_SYSTEM_DIR_INSTALL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/cppfs/cmake/cppfs")
# Overwriting original config
file(WRITE "${CURRENT_PACKAGES_DIR}/share/cppfs/cppfs-config.cmake" "
if(NOT \"${BUILD_SHARED_LIBS}\" AND \"${OPTION_BUILD_SSH_BACKEND}\")
    include(CMakeFindDependencyMacro)
    find_dependency(Libssh2 CONFIG)
    find_dependency(OpenSSL)
    find_dependency(ZLIB)
endif()
include(\"\${CMAKE_CURRENT_LIST_DIR}/cppfs-export.cmake\")
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cppfs" RENAME copyright)

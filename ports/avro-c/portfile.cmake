include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "Avro-c's buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF release-1.8.2
  SHA512 a48cc353aadd45ad2c8593bf89ec3f1ddb0fcd364b79dd002a60a54d49cab714b46eee8bd6dc47b13588b9eead49c754dfe05f6aff735752fca8d2cd35ae8649
  HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/avro.patch
        ${CMAKE_CURRENT_LIST_DIR}/avro-pr-217.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Snappy=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/lang/c/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/avro-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/avro-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/avro-c/copyright)

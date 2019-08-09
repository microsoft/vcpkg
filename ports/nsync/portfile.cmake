if(TARGET_TRIPLET STREQUAL "x64-windows-static")
    message(FATAL_ERROR "nsync does not support")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/nsync
    REF 1.21.0
    SHA512 39df3820d22f0c1c4dd0322601e82cb1feacc811ff3e5269c1339254fc87514046492a8565d634613b52459e8953e814786632c6d382a4d3f5e0cbaf25af09ad
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nsync)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nsync/LICENSE ${CURRENT_PACKAGES_DIR}/share/nsync/copyright)
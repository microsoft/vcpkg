vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kplotting
    REF v5.87.0
    SHA512 8437abe43e660b65e5c970039a343fee80c4e9bf1f3e1bf3b1a756fc211aa65192c0b6d7c10e42951a2fc5bec5ca8c45753d1ef009487865bb1e379025305410
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Plotting)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/plugins" "${CURRENT_PACKAGES_DIR}/debug/plugins")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/plugins" "${CURRENT_PACKAGES_DIR}/plugins")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

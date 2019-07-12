include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IronsDu/brynet
    REF e11fa11cee6cb03df081cfe81cb534bd2d26e319
    SHA512 12d1e4fd9f4eecac0f516ee8c87527b6287354317162cc73189fa04ed45dfd7f59f1a957dbf94191f60cf7b981c872eee988ff2f4df07d7c39c48169b02a75d6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brynet)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/brynet/LICENSE ${CURRENT_PACKAGES_DIR}/share/brynet/copyright)

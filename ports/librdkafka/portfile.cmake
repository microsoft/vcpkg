include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edenhill/librdkafka
    REF v0.11.6
    SHA512 9657dc53220bbff3eb44941cff2f50ab7f71a82f7486d64ea14f67eabd4abe8c67f225a752cc1f0339439a1cc512e99ade6536d087857979cd198c0102015718
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DRDKAFKA_BUILD_EXAMPLES=OFF
            -DRDKAFKA_BUILD_TESTS=OFF
)

vcpkg_install_cmake()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/librdkafka)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/librdkafka/LICENSE ${CURRENT_PACKAGES_DIR}/share/librdkafka/copyright)


vcpkg_copy_pdbs()



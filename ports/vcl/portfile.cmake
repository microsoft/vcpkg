
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vectorclass/version2
    REF 78cb733dc2ec23d59f2d93f510ca514407bb0a50
    SHA512 d14221075e79928b9a146c615e322a786f9a9b06ddd015bc343368816f104eb5c22b235e2013bcacdb801602d8d5f56673ec808ed8dda8c32b85959fb5107311
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME  ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

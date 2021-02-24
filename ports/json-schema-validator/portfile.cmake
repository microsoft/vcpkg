vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pboettch/json-schema-validator
    REF 27fc1d094503623dfe39365ba82581507524545c
    SHA512 4fd05087743f43871586a53d119acd1a19d0bdec8a5620f62b6eee7a926d285842e8439127eec52eeb11069c92b8d9af28558897d48e2422ecafca39d9f23cdb
    HEAD_REF master
    PATCHES
        fix-ambiguous-assignment.patch
        cmake-find-package.patch
        forward-find-package.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

set(PKG_NAME "nlohmann_json_schema_validator")
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PKG_NAME} TARGET_PATH share/${PKG_NAME})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})


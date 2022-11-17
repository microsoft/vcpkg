vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/json_dto
    REF 9a08aaab6caee28300043c96e1ad3e6700f0f8fc # v.0.3.1
    SHA512 09ca1072a3de2cc5c5ab6eeaa1b82014dcc6139992da84558e77fe4bfa42210ff9f7fa6ee7d7e6b2d4ac15fd7ae6286a6a56d8a72cce75fc73b91755bb831864
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/dev
    OPTIONS
        -DJSON_DTO_INSTALL=ON
        -DJSON_DTO_TEST=OFF
        -DJSON_DTO_SAMPLE=OFF
        -DJSON_DTO_INSTALL_SAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/json-dto)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


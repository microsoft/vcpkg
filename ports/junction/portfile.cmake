vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO preshing/junction
    REF 5ad3be7ce1d3f16b9f7ed6065bbfeacd2d629a08 # 2018-02-18
    SHA512 a3daee41e45be0ad79a4bdb2745dee04f1418020df5914dd04692304890936c9da60840efee249a2cc0618eea572102ca4b7ecc6f6711a37dac461c6b894fba1
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/Macros.cmake DESTINATION ${SOURCE_PATH}/cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DJUNCTION_WITH_SAMPLES=OFF
        -DTURF_PREFER_CPP11=1
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/json-dto)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

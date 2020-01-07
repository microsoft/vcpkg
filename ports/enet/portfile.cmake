vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO lsalzman/enet
    REF 0eaf48eeb0d94a18d079378d8b76d588832ce838
    HEAD_REF master
    SHA512 9bf867742b4f0e31be30aed1c3b113b3495857af4db1daf54fce38d3b30cbf62348957c7f660f80a38a9b432cbb44e9068d7f579e55d34dc973bea02755eb3ae
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

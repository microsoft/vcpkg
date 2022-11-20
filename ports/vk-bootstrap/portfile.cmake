vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charles-lunarg/vk-bootstrap
    REF 142986cdb767037118b687387b097ff6b3e7fe7d
    SHA512 1dc32f09f4548ffaf71d39d5200d60a9bd58971327039f2adb4327fdb885f984bbd91409d28dbfc24e5fdac8c241824e141a2558cddc1b86b84cf2376e7d7567
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/${PORT}-config.cmake" "${CMAKE_CURRENT_LIST_DIR}/${PORT}-targets-release.cmake" "${CMAKE_CURRENT_LIST_DIR}/${PORT}-targets-debug.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

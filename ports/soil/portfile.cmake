vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paralin/soil
    REF 8bb18a909f94e58afbc0bda941ffc6eee58b4066 # committed on 2014-03-06
    SHA512 6cbaa10d8b2a274c389fda723db53a3f1ba7d25a7367df40efec4d0553c09f0d67fb16f927bba2ff0aed4234e3a83922edcc574ffac72dd7e05d6cec768b561b
    HEAD_REF master
    PATCHES fix-cmakelists.patch
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/soilConfig.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/soilConfigVersion.cmake.in
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mrtazz/restclient-cpp
    REF 3b2d507dbef4332af490b0a861477a56d0e83fcd
    SHA512 2b23e81ba6dd70357e4f04c152b41c6b962f02cf91a7efb509298f709d1da00a77801da3ebefa698deaad7e60269eb377e780181e252b09af9b26878b2ff8a5d
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/version.h DESTINATION ${SOURCE_PATH}/include/restclient-cpp)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restclient RENAME copyright)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restclient RENAME copyright)

vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO littlstar/soil
    REF 475f3d83433582618aae8a3c89eb978b01e263a3 # 0.1.0
    SHA512 89da87da9c9f21ba7ccfbff6f6c46f2463f672d2ce13a37a9b161eeef471f5a31fa751c80dba9378c77d878148ca77012dec861461d3a7b6966a34951157ae2f
    HEAD_REF master
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/SOILConfig.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/SOILConfigVersion.cmake.in
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

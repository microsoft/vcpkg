vcpkg_fail_port_install(ON_TARGET "UWP" ON_TARGET "x86" "arm" "aarch64")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO jandrewrogers/MetroHash
        REF 690a521d9beb2e1050cc8f273fdabc13b31bf8f6
        SHA512 51ba58a43f7a60be823746082c1bdebf52a1fd452a0f778434850ccc71dd6f62750fc966ec6aed6b4b523279ad400733df3f56544e2d2e057c212044a2dc16a4
        HEAD_REF master
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)
configure_file(${CURRENT_PORT_DIR}/Config.cmake.in ${SOURCE_PATH}/cmake/Config.cmake.in COPYONLY)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SLikeSoft/SLikeNet
    REF 358462052fce7e585fc1cce0a17a7042ba724c08
    SHA512 2c932b0a7910ec36dd6a340dd841cefcf259fbdadadff220747d13752181ea14e3c5f05331beb36dea21c0de360edc270ff4c55375bbea23ee2149828f07e9ab
    HEAD_REF master
    PATCHES
        fix-install.patch
)
#Uses an outdated OpenSSL version and is in an experimental namespace any way. As such we delete it here
file(REMOVE_RECURSE "${SOURCE_PATH}/Source/src/crypto" "${SOURCE_PATH}/Source/include/slikenet/crypto")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SLIKENET_ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SLIKENET_ENABLE_DLL)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSLIKENET_ENABLE_DLL=${SLIKENET_ENABLE_DLL}
        -DSLIKENET_ENABLE_STATIC=${SLIKENET_ENABLE_STATIC}
        -DSLIKENET_ENABLE_SAMPLES=FALSE
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/slikenet)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file("${CMAKE_CURRENT_LIST_DIR}/slikenet-config.cmake" "${CURRENT_PACKAGES_DIR}/share/slikenet/slikenet-config.cmake" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/slikenet/vcpkg-cmake-wrapper.cmake" COPYONLY)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

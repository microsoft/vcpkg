vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO materialx/MaterialX
    REF cc2de8f4cfbda8870159194637ea43324a9110fc
    SHA512 09313496ca342c61fe66ed8da68d81d694f49ae572dbda8a1693b137d2169a02697843cab3de96e80d459425885c0f19e8fd4d5aab4b4d64f241a37f55c65ef7
    HEAD_REF master
)

if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "MaterialX currently requires the following libraries from the system package manager:\n    libx11\n    libxt\n    freeglut3\n\nThese can be installed on Ubuntu systems via sudo apt-get install libx11-dev libxt-dev freeglut3-dev")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake/modules)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/MaterialXRender/External/OpenImageIO)
file(COPY ${CURRENT_PACKAGES_DIR}/resources DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${CURRENT_PACKAGES_DIR}/debug/resources DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/resources)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/resources)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/libraries)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/libraries)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
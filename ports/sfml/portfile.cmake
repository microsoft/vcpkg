vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO SFML/SFML
    REF 2.5.1
    HEAD_REF master
    SHA512 7aed2fc29d1da98e6c4d598d5c86cf536cb4eb5c2079cdc23bb8e502288833c052579dadbe0ce13ad6461792d959bf6d9660229f54c54cf90a541c88c6b03d59
    PATCHES
        fix-dependencies.patch
        arm64.patch
)

# The embedded FindFreetype doesn't properly handle debug libraries
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/Modules/FindFreetype.cmake")

if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "SFML currently requires the following libraries from the system package manager:\n    libudev\n    libx11\n    libxrandr\n    opengl\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libxrandr-dev libxi-dev libudev-dev libgl1-mesa-dev")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSFML_BUILD_FRAMEWORKS=OFF
        -DSFML_USE_SYSTEM_DEPS=ON
        -DSFML_MISC_INSTALL_PREFIX=share/sfml
        -DSFML_GENERATE_PDB=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SFML)
vcpkg_copy_pdbs()

# move sfml-main to manual link dir
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib")
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib")
    file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib")
    file(GLOB FILES "${CURRENT_PACKAGES_DIR}/share/sfml/SFML*Targets-*.cmake")
    foreach(FILE ${FILES})
        vcpkg_replace_string("${FILE}" "/lib/sfml-main" "/lib/manual-link/sfml-main")
    endforeach()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_fixup_pkgconfig()

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
configure_file("${SOURCE_PATH}/license.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

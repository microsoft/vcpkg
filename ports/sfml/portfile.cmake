vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO SFML/SFML
    REF 2.5.1
    HEAD_REF master
    SHA512 7aed2fc29d1da98e6c4d598d5c86cf536cb4eb5c2079cdc23bb8e502288833c052579dadbe0ce13ad6461792d959bf6d9660229f54c54cf90a541c88c6b03d59
    PATCHES
        use-system-freetype.patch
        stb_include.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/extlibs)
# Without this, we get error: list sub-command REMOVE_DUPLICATES requires list to be present.
file(MAKE_DIRECTORY ${SOURCE_PATH}/extlibs/libs)
file(WRITE ${SOURCE_PATH}/extlibs/libs/x "")
# The embedded FindFreetype doesn't properly handle debug libraries
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/Modules/FindFreetype.cmake)

if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "SFML currently requires the following libraries from the system package manager:\n    libudev\n    libx11\n    libxrandr\n    opengl\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libxrandr-dev libxi-dev libudev-dev libgl1-mesa-dev")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSFML_BUILD_FRAMEWORKS=OFF
        -DSFML_USE_SYSTEM_DEPS=ON
        -DSFML_MISC_INSTALL_PREFIX=share/sfml
        -DSFML_GENERATE_PDB=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SFML)
vcpkg_copy_pdbs()

FILE(READ ${CURRENT_PACKAGES_DIR}/share/sfml/SFMLConfig.cmake SFML_CONFIG)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    FILE(WRITE ${CURRENT_PACKAGES_DIR}/share/sfml/SFMLConfig.cmake "set(SFML_STATIC_LIBRARIES true)\ninclude(CMakeFindDependencyMacro)\nfind_dependency(Freetype)\n${SFML_CONFIG}")
else()
    FILE(WRITE ${CURRENT_PACKAGES_DIR}/share/sfml/SFMLConfig.cmake "set(SFML_STATIC_LIBRARIES false)\n${SFML_CONFIG}")
endif()

# move sfml-main to manual link dir
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib)
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib)
    file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib)
    file(GLOB FILES "${CURRENT_PACKAGES_DIR}/share/sfml/SFML*Targets-*.cmake")
    foreach(FILE ${FILES})
        file(READ "${FILE}" _contents)
        string(REPLACE "/lib/sfml-main" "/lib/manual-link/sfml-main" _contents "${_contents}")
        file(WRITE "${FILE}" "${_contents}")
    endforeach()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/license.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
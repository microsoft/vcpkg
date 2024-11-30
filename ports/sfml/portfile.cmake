vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO SFML/SFML
    REF "${VERSION}"
    HEAD_REF master
    SHA512 d8a8bee3aa9acda4609104c2a9d4a2512e4be6d6e85fd4b24c287c03f60cfb888e669e61bfac4113dae35f0c3492559b65b3453baf38766d8c0223d9ab77aada
    PATCHES
        fix-dependencies.patch
        fix-dep-openal.patch
)

# The embedded FindFreetype doesn't properly handle debug libraries
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/Modules/FindFreetype.cmake")

if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "SFML currently requires the following libraries from the system package manager:\n    libudev\n    libx11\n    libxrandr\n    libxcursor\n    opengl\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libxrandr-dev libxcursor-dev libxi-dev libudev-dev libgl1-mesa-dev")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "network"  SFML_BUILD_NETWORK
        "graphics" SFML_BUILD_GRAPHICS
        "window"   SFML_BUILD_WINDOW
        "audio"    SFML_BUILD_AUDIO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSFML_BUILD_FRAMEWORKS=OFF
        -DSFML_USE_SYSTEM_DEPS=ON
        -DSFML_MISC_INSTALL_PREFIX=share/sfml
        -DSFML_GENERATE_PDB=OFF
        -DSFML_WARNINGS_AS_ERRORS=OFF #Remove in the next version
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        SFML_MISC_INSTALL_PREFIX
        SFML_WARNINGS_AS_ERRORS
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SFML)
vcpkg_copy_pdbs()

# move sfml-main to manual link dir
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib")
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib")
    file(GLOB FILES "${CURRENT_PACKAGES_DIR}/share/sfml/SFML*Targets-*.cmake")
    foreach(FILE ${FILES})
        vcpkg_replace_string("${FILE}" "/lib/sfml-main" "/lib/manual-link/sfml-main")
    endforeach()
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib")
    file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

set(SHOULD_REMOVE_SFML_ALL 0)
if(NOT "audio" IN_LIST FEATURES)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sfml-audio.pc")
    set(SHOULD_REMOVE_SFML_ALL 1)
endif()
if(NOT "graphics" IN_LIST FEATURES)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sfml-graphics.pc")
    set(SHOULD_REMOVE_SFML_ALL 1)
endif()
if(NOT "network" IN_LIST FEATURES)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sfml-network.pc")
    set(SHOULD_REMOVE_SFML_ALL 1)
endif()
if(NOT "window" IN_LIST FEATURES)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sfml-window.pc")
    set(SHOULD_REMOVE_SFML_ALL 1)
endif()
if(SHOULD_REMOVE_SFML_ALL)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sfml-all.pc")
endif()

vcpkg_fixup_pkgconfig()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.md")

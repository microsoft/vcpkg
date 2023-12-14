vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO SFML/SFML
    REF "${VERSION}"
    HEAD_REF master
    SHA512 b376d3b00277ed60d107fe1268c210749b3aafcee618a8f924b181a9b476e92b9cb9baddecf70a8913b5910c471d53ea0260a876ad7b2db2b98b944d9f508714
    PATCHES
        fix-dependencies.patch
)

# The embedded FindFreetype doesn't properly handle debug libraries
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/Modules/FindFreetype.cmake")

if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "SFML currently requires the following libraries from the system package manager:\n    libudev\n    libx11\n    libxrandr\n    libxcursor\n    opengl\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libxrandr-dev libxcursor-dev libxi-dev libudev-dev libgl1-mesa-dev")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSFML_BUILD_FRAMEWORKS=OFF
        -DSFML_USE_SYSTEM_DEPS=ON
        -DSFML_MISC_INSTALL_PREFIX=share/sfml
        -DSFML_GENERATE_PDB=OFF
        -DSFML_WARNINGS_AS_ERRORS=OFF #Remove in the next version
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

vcpkg_fixup_pkgconfig()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.md")

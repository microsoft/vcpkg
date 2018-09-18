
include(vcpkg_common_functions)
vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO SFML/SFML
    REF 2.5.0
    HEAD_REF master
    SHA512 94306dcbed7d68bb7e226cd91e25950a07bcf393988c4bb79f9de3555c18c78cae4573e911235f712e711a7c02a614bf370df32b8d85240d2f08142327e05076
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/use-system-freetype.patch"
)

file(REMOVE_RECURSE ${SOURCE_PATH}/extlibs)
# Without this, we get error: list sub-command REMOVE_DUPLICATES requires list to be present.
file(MAKE_DIRECTORY ${SOURCE_PATH}/extlibs/libs)
file(WRITE ${SOURCE_PATH}/extlibs/libs/x "")
# The embedded FindFreetype doesn't properly handle debug libraries
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/Modules/FindFreetype.cmake)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message("SFML currently requires the following libraries from the system package manager:\n    libudev\n    libx11\n    libxrandr\n    opengl\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libxrandr-dev libxi-dev libudev-dev mesa-common-dev")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSFML_BUILD_FRAMEWORKS=OFF
        -DSFML_USE_SYSTEM_DEPS=ON
        -DSFML_MISC_INSTALL_PREFIX=share/sfml
        -DSFML_GENERATE_PDB=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SFML)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    FILE(READ ${CURRENT_PACKAGES_DIR}/share/sfml/SFMLConfig.cmake SFML_CONFIG)
    FILE(WRITE ${CURRENT_PACKAGES_DIR}/share/sfml/SFMLConfig.cmake "set(SFML_STATIC_LIBRARIES true)\n${SFML_CONFIG}")
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

file(INSTALL ${SOURCE_PATH}/license.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfml RENAME copyright)

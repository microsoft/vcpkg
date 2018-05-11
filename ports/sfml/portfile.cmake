
include(vcpkg_common_functions)
vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO SFML/SFML
    REF 2.4.2
    HEAD_REF master
    SHA512 8acfdf320939c953a9a3413398f82d02d68a56a337f1366c2677c14ce032baa8ba059113ac3c91bb6e6fc22eef119369a265be7ef6894526e6a97a01f37e1972
)

file(REMOVE_RECURSE ${SOURCE_PATH}/extlibs)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message("SFML currently requires the following libraries from the system package manager:\n    libudev\n    libx11\n    libxrandr\n    opengl\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libxrandr-dev libxi-dev libudev-dev mesa-common-dev")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DSFML_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# don't force users to define SFML_STATIC while using static library
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(APPEND ${CURRENT_PACKAGES_DIR}/include/SFML/Config.hpp "#undef SFML_API_IMPORT\n#define SFML_API_IMPORT\n")
endif()

# move sfml-main to manual link dir
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib)
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib)
    file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib)
endif()

# At the time of writing, HEAD has license.md instead of license.txt
if(VCPKG_HEAD_VERSION)
    file(INSTALL ${SOURCE_PATH}/license.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfml RENAME copyright)
else()
    file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfml RENAME copyright)
endif()
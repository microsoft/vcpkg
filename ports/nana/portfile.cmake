if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(WARNING "You will need to install Xorg dependencies to use nana:\napt install libx11-dev libxft-dev\n")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnjinhao/nana
    REF v1.5.6
    SHA512 6fccefcab845b3eeac08da39bb74ce53f8d83e0686fbc2375d35025427df5838b5194a727732ddf495427ac16af1c4428deb9e00a6e1d824725246d434529167
    HEAD_REF develop
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNANA_ENABLE_PNG=ON
        -DNANA_ENABLE_JPEG=ON
    OPTIONS_DEBUG
        -DNANA_INSTALL_HEADERS=OFF)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-nana TARGET_PATH share/unofficial-nana)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nana)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nana/LICENSE ${CURRENT_PACKAGES_DIR}/share/nana/copyright)

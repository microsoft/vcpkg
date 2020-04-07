vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_TARGET_IS_UWP)
    message(WARNING "You will need to install Xorg dependencies to use nana:\napt install libx11-dev libxft-dev libxcursor-dev\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnjinhao/nana
    REF 38cdf4779456ba697d7da863f7c623e25d30f650 # v1.7.2
    SHA512 0ad15984ce6ef94b4f92b2a87649c0e247850a602a8f48645fd882ed5dddd047a168c319c741b2783218ce467f8d0ac790010717cffc54cb1716b105ec042798
    HEAD_REF develop
    PATCHES
        fix-build-error.patch
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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

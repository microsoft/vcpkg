vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "You will need to install Xorg dependencies to use nana:\napt install libx11-dev libxft-dev libxcursor-dev\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnjinhao/nana
    REF 554c4fe87fc31b8ee104228e9117d545d34855b5 # v1.7.4
    SHA512 d9db8ea1bd47fe663b8e2443a1a3e279760dbd11ef6bc78d9dc8f6fd12f9736b8c8315dfc84d21325e02ad6b2dc3a429593ac80e7610097ddc7253668c383178
    HEAD_REF develop
    PATCHES
        fix-build-error.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANA_ENABLE_PNG=ON
        -DNANA_ENABLE_JPEG=ON
    OPTIONS_DEBUG
        -DNANA_INSTALL_HEADERS=OFF)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-nana)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cycfi/elements
    REF 28ede99e37597d743979b127191df45ace11f58b
    SHA512 4ab2952d64a6c19de15b24db9bf4523ba26c274847dedf7f1d36b09e5fda0656d0b83d9aa310cc0a81b23c894a8ad00c6a88afc9b0b6c1e76b6469f8bb01603c
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH INFRA_SOURCE_PATH
    REPO cycfi/infra
    REF 2dff97a4b107eced78e426152f5001a2331cb1cf
    SHA512 a679e70fe1751e0a6be7b7449d7f4bf36e59ea355e44ddef4902b784f521e264bfc009ec0792ef7fb04ffbc187f0e99116a615e8bdf7932abd34cafc0d7cdfff
    HEAD_REF master
)
if(NOT EXISTS "${SOURCE_PATH}/lib/infra/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/lib/infra")
    file(RENAME "${INFRA_SOURCE_PATH}" "${SOURCE_PATH}/lib/infra")
endif()


if(VCPKG_TARGET_IS_WINDOWS)
    set(ELEMENTS_HOST_UI_LIBRARY "win32")
elseif(VCPKG_TARGET_IS_OSX)
    set(ELEMENTS_HOST_UI_LIBRARY "cocoa")
else()
    set(ELEMENTS_HOST_UI_LIBRARY "gtk")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DELEMENTS_BUILD_EXAMPLES=OFF
        -DELEMENTS_HOST_UI_LIBRARY=${ELEMENTS_HOST_UI_LIBRARY}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_build()

file(INSTALL "${SOURCE_PATH}/lib/include/elements.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/include/elements" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/infra/include/infra" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")

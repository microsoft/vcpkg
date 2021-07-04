vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fallahn/tmxlite
    REF 591dd0371dceb2c43abeceac11cd9e8077880cca
    HEAD_REF master
    SHA512 a857aea3ec99c686e97d25ecb2bdd8d2f2f14dcb8419e14535ace8794bfbc21fe825cffc60e589df7291ae35076fb6734f7047c985a6ea6d0c55c861c07ba784
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/tmxlite
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

configure_file(${SOURCE_PATH}/readme.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
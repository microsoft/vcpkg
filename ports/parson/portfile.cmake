include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("parson only supports static linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kgabis/parson
    REF 302fba9cbb31ffc523bf10a1ce705040194c289d
    SHA512 ecc1594fe6e27b8919ccdaf3c7e082d0d47aa5e20aec52235762b9cab8e371adec5a1760f4ea36405bf97cfb587d2bcbd81221f97a9d39290673e2ce61f5a49f
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/parson.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-parson TARGET_PATH share/unofficial-parson)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/parson RENAME copyright)

vcpkg_copy_pdbs()

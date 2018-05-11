include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("parson only supports static linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kgabis/parson
    REF 921da6f5d7b82ac3c8c809341028daafe47e3210
    SHA512 fac1989d03148c1efec5e483704e76110c6575258c7ad0585f4598c1666b22804b8bd672fa31869227b5334fb1ba0b70eb380a971950df1a8f52e56e646956d9
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

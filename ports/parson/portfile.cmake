include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("parson only supports static linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kgabis/parson
    REF 33e5519d0ae68784c91c92af2f48a5b07dc14490
    SHA512 b4477fe1038465edb210d1d02c8241ba02c44a01fa7838fb6217b36659eae3c5eaf450ec559bd609dfdc2417b4948eacc4a643ed7f1684f9b4bbaded421d7b80
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

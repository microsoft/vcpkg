set(OATPP_VERSION "0.19.12")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

message(STATUS "Building oatpp-consul")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-consul
    REF 97984c5b3239902011e92bc1a1f6ca157ff47957 # 0.19.12
    SHA512 621c66f449f3ccf818cfe39519a9329e7027d774ff824811a4c936f9d017bff6a0e6d96930cd1a3f51db81dcec5b94b746ad11c2cfd500a5eeeb953355d992dd
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "ON")
else()
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
        "-DBUILD_SHARED_LIBS:BOOL=${OATPP_BUILD_SHARED_LIBRARIES_OPTION}"
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-consul-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

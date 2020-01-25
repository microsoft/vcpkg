set(OATPP_VERSION "0.19.12")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

message(STATUS "Building oatpp-swagger")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-swagger
    REF a13bae1f32cea2ef011395ed92ae81f0f4b43aa7 # 0.19.12
    SHA512 a7169970dde1c8c5d12a0fd9bf6a6af0a23e548e4e73a4d436aabcf088643cf7d193e9a2e31eac60fa97592c2904b473e624b189874705511f64686faecfc851
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-swagger-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

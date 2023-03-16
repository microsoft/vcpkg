if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO idealvin/coost
    REF "v${VERSION}"
    SHA512 73720a430cb0f5480fcbb5e92d536f07e3a60fa30ca2d60be5ba11f1d5b2bee35da320f8200c18000ff0b1de50e18be0850fab945b48525319bcd198b388fcf6
    HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(STATIC_VS_CRT ON)
else()
    set(STATIC_VS_CRT OFF)
endif()


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_ALL=OFF
)
vcpkg_cmake_install()

file(INSTALL ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${CURRENT_PACKAGES_DIR}/lib/cmake/ DESTINATION ${CURRENT_PACKAGES_DIR}/share)
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")

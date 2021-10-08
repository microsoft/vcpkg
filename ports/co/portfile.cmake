if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    vcpkg_fail_port_install(ON_ARCH "arm" ON_TAREGT "uwp")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO idealvin/co
    REF 25915760f5cbcde1c5af625dd4d19a632ae43f12 #v2.0.2
    SHA512 892d70923409306ab548cf4568f15ffd13949047a5a7810c68d60c1afd184eafd2076f62eb6249ae64b38c409255cb873fa28740ceab37b908b70174ddf6d077
    HEAD_REF master
    PATCHES
        install-dll.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libcurl    WITH_LIBCURL
        openssl    WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSTATIC_VS_CRT=${STATIC_CRT}
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

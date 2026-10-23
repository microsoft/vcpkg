vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sigmyne/smax-clib
    REF "v${VERSION}"
    SHA512 1acc8c63e11c522c5cdc6e6b2c22aea974812efd640f6a23bb6bbf5f0716f2b745a3ca03aab2ef9856322934274af21bf92a22ba943eaa8c85d4cb255bb260fd
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls              ENABLE_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_CLI=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/smax" PACKAGE_NAME "smax")

foreach(config IN ITEMS "" "/debug")
    set(pc "${CURRENT_PACKAGES_DIR}${config}/lib/pkgconfig/smax.pc")
    if(EXISTS "${pc}")
        vcpkg_replace_string("${pc}" "Name: redisx" "Name: smax")
        vcpkg_replace_string("${pc}" "-lxchange -lxchange " "-lredisx -lxchange ")
        if(VCPKG_TARGET_IS_WINDOWS)
            vcpkg_replace_string("${pc}" "Libs.private: " "Libs.private: -lws2_32 ")
        endif()
        if(config STREQUAL "/debug")
            vcpkg_replace_string("${pc}" "-lsmax " "-lsmaxd ")
            vcpkg_replace_string("${pc}" "-lredisx " "-lredisxd ")
            vcpkg_replace_string("${pc}" "-lxchange " "-lxchanged ")
        endif()
    endif()
endforeach()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

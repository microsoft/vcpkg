include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF D79545391546EE63B80687B2FE25D189DB113751
        SHA512 3BF8761B15E78DF68526A01D460074B0AD51B3DD2E49F12A9420202446C8C24274BC48AE8F22A59021B422F0F93FC97BFF849F106A9698A05AEA2D3A956E00CA
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF D79545391546EE63B80687B2FE25D189DB113751
        SHA512 3BF8761B15E78DF68526A01D460074B0AD51B3DD2E49F12A9420202446C8C24274BC48AE8F22A59021B422F0F93FC97BFF849F106A9698A05AEA2D3A956E00CA
        HEAD_REF master
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/c-utility/configs/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/uhttp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-uhttp-c/copyright COPYONLY)

vcpkg_copy_pdbs()



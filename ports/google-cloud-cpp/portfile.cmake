vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/google-cloud-cpp
    REF v1.35.0
    SHA512 99eabb37ff32ddaf8f646415b50f3843e89fb119646428c16f03060c2787c8d86fa1ac0919ee60c4f6c7a3b71a14eb828ae26a7fc26d928543d72c7ba3268bff
    HEAD_REF main
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/grpc")

set(GOOGLE_CLOUD_CPP_ENABLE "${FEATURES}")
list(REMOVE_ITEM GOOGLE_CLOUD_CPP_ENABLE "core")
list(REMOVE_ITEM GOOGLE_CLOUD_CPP_ENABLE "googleapis")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DGOOGLE_CLOUD_CPP_ENABLE=${GOOGLE_CLOUD_CPP_ENABLE}"
        -DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF
        -DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF
        -DGOOGLE_CLOUD_CPP_ENABLE_CCACHE=OFF
        -DGOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
foreach(feature IN LISTS FEATURES)
    set(config_path "lib/cmake/google_cloud_cpp_${feature}")
    # Most features get their own package in `google-cloud-cpp`.
    # The exceptions are captured by this `if()` command, basically
    # things like `core` and `experimental-storage-grpc` are skipped.
    if(NOT IS_DIRECTORY "${CURRENT_PACKAGES_DIR}/${config_path}")
        continue()
    endif()
    vcpkg_cmake_config_fixup(PACKAGE_NAME "google_cloud_cpp_${feature}"
                             CONFIG_PATH "${config_path}"
                             DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
# These packages are automatically installed depending on what features are
# enabled.
foreach(suffix common googleapis grpc_utils)
    set(config_path "lib/cmake/google_cloud_cpp_${suffix}")
    if(NOT IS_DIRECTORY "${CURRENT_PACKAGES_DIR}/${config_path}")
        continue()
    endif()
    vcpkg_cmake_config_fixup(PACKAGE_NAME "google_cloud_cpp_${suffix}"
                             CONFIG_PATH "${config_path}"
                             DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()

# These packages are only for backwards compability. The google-cloud-cpp team
# is planning to remove them around 2022-02-15.
foreach(package
        googleapis
        bigtable_client
        pubsub_client
        spanner_client
        storage_client)
    set(config_path "lib/cmake/${package}")
    if(NOT IS_DIRECTORY "${CURRENT_PACKAGES_DIR}/${config_path}")
        continue()
    endif()
    vcpkg_cmake_config_fixup(PACKAGE_NAME "${package}"
                             CONFIG_PATH "${config_path}"
                             DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share") 
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/google-cloud-cpp
    REF v2.3.0
    SHA512 094b8607aab0fc69a0999f63c4f4ed0d23a3658215192229968dfcf24ae3c9610821dc0e9b0da61edf192fcbf554e23cd4f9979c57ff6103011251012fb28596
    HEAD_REF main
    PATCHES
        support_absl_cxx17.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/grpc")

set(GOOGLE_CLOUD_CPP_ENABLE "${FEATURES}")
list(REMOVE_ITEM GOOGLE_CLOUD_CPP_ENABLE "core")
# This feature does not exist, but allows us to simplify the vcpkg.json file.
list(REMOVE_ITEM GOOGLE_CLOUD_CPP_ENABLE "grpc-common")
list(REMOVE_ITEM GOOGLE_CLOUD_CPP_ENABLE "googleapis")
# google-cloud-cpp uses dialogflow_cx and dialogflow_es. Underscores
# are invalid in `vcpkg` features, we use dashes (`-`) as a separator
# for the `vcpkg` feature name, and convert it here to something that
# `google-cloud-cpp` would like.
if ("dialogflow-cx" IN_LIST FEATURES)
    list(REMOVE_ITEM GOOGLE_CLOUD_CPP_ENABLE "dialogflow-cx")
    list(APPEND GOOGLE_CLOUD_CPP_ENABLE "dialogflow_cx")
endif ()
if ("dialogflow-es" IN_LIST FEATURES)
    list(REMOVE_ITEM GOOGLE_CLOUD_CPP_ENABLE "dialogflow-es")
    list(APPEND GOOGLE_CLOUD_CPP_ENABLE "dialogflow_es")
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
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
foreach(suffix common googleapis grpc_utils rest_internal dialogflow_cx dialogflow_es)
    set(config_path "lib/cmake/google_cloud_cpp_${suffix}")
    if(NOT IS_DIRECTORY "${CURRENT_PACKAGES_DIR}/${config_path}")
        continue()
    endif()
    vcpkg_cmake_config_fixup(PACKAGE_NAME "google_cloud_cpp_${suffix}"
                             CONFIG_PATH "${config_path}"
                             DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

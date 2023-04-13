if(TARGET_TRIPLET MATCHES "(uwp|arm)")
    message(FATAL_ERROR "septag-sx doesn't support ${TARGET_TRIPLET} currently.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO septag/sx
    REF b70567a52636f9ecfdb904c586a957a806efc990
    SHA512 8945476b428418d3c7845afd831503f43fd44672a9b3506576c5baf50f55739327275a8be97a323f3ae146f84b76bbe266ac7b5df1b85cb05a826ed5e30b9547
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SX_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSX_BUILD_TESTS=OFF
        -DSX_SHARED_LIB=${SX_SHARED_LIB}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sx PACKAGE_NAME sx)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sx/config.h"
        "define SX_CONFIG_SHARED_LIB 0"
        "define SX_CONFIG_SHARED_LIB 1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

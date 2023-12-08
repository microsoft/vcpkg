vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF REL_2_1_1
    SHA512 ddc63ad574aed7d13980308c1f4d3a31a7fa9c7d4a14de923f9b3a851492d17f64f34166b6be77fc8584c0e98cd1f34ed3d9ba268e7456fd1ff3b7d8125dbe3a
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH THREADPOOL_SOURCE_PATH
    REPO log4cplus/ThreadPool
    REF 3507796e172d36555b47d6191f170823d9f6b12c
    SHA512 6b46ce287d68fd0cda0c69fda739eaeda89e1ed4f086e28a591f4e50aaf80ee2defc28ee14a5bf65be005c1a6ec4f2848d5723740726c54d5cc1d20f8e98aa0c
    HEAD_REF master
)

file(
    COPY
        "${THREADPOOL_SOURCE_PATH}/COPYING"
        "${THREADPOOL_SOURCE_PATH}/example.cpp"
        "${THREADPOOL_SOURCE_PATH}/README.md"
        "${THREADPOOL_SOURCE_PATH}/ThreadPool.h"
    DESTINATION "${SOURCE_PATH}/threadpool"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unicode UNICODE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLOG4CPLUS_BUILD_TESTING=OFF
        -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF
        -DWITH_UNIT_TESTS=OFF
        -DLOG4CPLUS_ENABLE_DECORATED_LIBRARY_NAME=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/log4cplus)
vcpkg_copy_pdbs()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/log4cplus.pc" "-llog4cplus" "-llog4cplusD")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/ChangeLog"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/README.md")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

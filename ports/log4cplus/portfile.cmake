vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF REL_2_1_2
    SHA512 37d37107f327cf343784d68ea4a18ee7eaa0a943e56075ebd14318b8905954649501f0228c6086058d89f97a332e73cabfc64ea7290ae79578fd583590661b94
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH THREADPOOL_SOURCE_PATH
    REPO log4cplus/ThreadPool
    REF 251db61ff3e3c7b16436c9936c53e6f68ff07720
    SHA512 41452423720762246380ec7e8c3a8e4f5bd1e8e0467a66126419d50a30ffead1c87a5af6f322275e188870a3e5d4abc9802967ab4453dc29c65ec0add0b5ae31
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

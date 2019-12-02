vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jupp0r/prometheus-cpp
    REF ca1f3463e74d957d1cccddd4a1a29e3e5d34bd83 # v0.8.0
    SHA512 63e9444c1cbe986ea398e8cbcbca502b15bb7589c50831d47ec7f7e3278d8e1acd4150f661a6a2698f37f8e0cab00d6a9ba14bdaee39792c0409f853766f7069
    HEAD_REF master
)

macro(feature FEATURENAME OPTIONNAME)
    if("${FEATURENAME}" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS -D${OPTIONNAME}=TRUE)
    else()
        list(APPEND FEATURE_OPTIONS -D${OPTIONNAME}=FALSE)
    endif()
endmacro()

feature(compression ENABLE_COMPRESSION)
feature(pull ENABLE_PULL)
feature(push ENABLE_PUSH)
feature(tests ENABLE_TESTING)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_THIRDPARTY_LIBRARIES=OFF # use vcpkg packages
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/prometheus-cpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
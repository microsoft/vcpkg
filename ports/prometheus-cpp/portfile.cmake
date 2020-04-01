include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jupp0r/prometheus-cpp
    REF v0.9.0
    SHA512 d9d5fbbd8c8aad5dd6a5e872275324d689a0c57199e4158d74e13ea62b286fa71dee01bb4197b906b79792bf1ca4e67a46b5c04621d7070241ac32876f6de891
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
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/prometheus-cpp/copyright COPYONLY)

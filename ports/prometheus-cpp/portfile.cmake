include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jupp0r/prometheus-cpp
    REF v0.6.0
    SHA512 a7e6f902f3007007ec68add5ac63e833c6f383ed0ce103e238b7248497f495e664446df7801000e36021adcb7cfb1d461bbb45e1b4fba9ffa4edfcaf5b5957dd
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_THIRDPARTY_LIBRARIES=OFF # use vcpkg packages
        -DENABLE_TESTING=FALSE # need gtest 1.8.1
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/prometheus-cpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/prometheus-cpp/copyright COPYONLY)

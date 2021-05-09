vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jupp0r/prometheus-cpp
    REF 2412990ee9ad89245e7d1df9ec85ab19b24674d3 # v0.12.2
    SHA512 52ecf1984c709dab749f2b4b0010796be49b9db5416678baf77f645054f85b1cae4d67f06ffb1643c0fbcfbf2e65c81f2157a22c0b75a346f9b1feba6537b87d
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
        -DGENERATE_PKGCONFIG=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/prometheus-cpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

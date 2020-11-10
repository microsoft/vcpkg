if("v2" IN_LIST FEATURES)
    set(USE_V2 ON)
endif()

if(USE_V2)
    set(GIT_REF ff349a50bfc6214b4081f4ca63c7de35e2162f60) # v2.13.3
    set(GIT_SHA512 488c95ba5c5f80019abc4f61b3b50536e3dc71f7bf87d51c56cc5928cf32cac0e535e1b08eb4e8e435665e81bf0156f83013ba31a1b3d2b61c692fbf7f019d25)
else()
    set(GIT_REF b9853b4b356b83bb580c746c3a1f11101f9af54f) # v3.0.0-preview3
    set(GIT_SHA512 0223374e44e0198aece32338006534dfc839b253184a4a9468708672f2efc164b083d57b9c83ed694698959c282238bc99b4db77246f9472f89c1d2f330d5c0a)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF ${GIT_REF}
    SHA512 ${GIT_SHA512}
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCATCH_BUILD_EXAMPLES=OFF
        -DCATCH_INSTALL_DOCS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Catch2)

if(USE_V2)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
else()
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug/include
        ${CURRENT_PACKAGES_DIR}/debug/share
        ${CURRENT_PACKAGES_DIR}/include/catch2/benchmark/internal 
        ${CURRENT_PACKAGES_DIR}/include/catch2/generators/internal
    )
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

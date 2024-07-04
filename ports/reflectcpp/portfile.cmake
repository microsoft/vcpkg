vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO getml/reflect-cpp
    REF "c00e98ce371adf41283baae080bec3700bac7df3"
    SHA512 a8e0c92367585f56aefcb356a6706f1137a2ca1eab5caab68ea883eec1253c6440148c370b10df6b2b98b0b508bc264416e929d016a7f11bf6efe426340ba9d4
    HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" REFLECTCPP_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DREFLECTCPP_BUILD_TESTS=OFF
        -DREFLECTCPP_BUILD_SHARED=${REFLECTCPP_BUILD_SHARED}
        -DREFLECTCPP_USE_BUNDLED_DEPENDENCIES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

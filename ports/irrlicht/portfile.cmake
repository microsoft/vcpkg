vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "osx" "uwp")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO irrlicht/Irrlicht%20SDK
    REF 1.8/1.8.4
    FILENAME "irrlicht-1.8.4.zip"
    SHA512 de69ddd2c6bc80a1b27b9a620e3697b1baa552f24c7d624076d471f3aecd9b15f71dce3b640811e6ece20f49b57688d428e3503936a7926b3e3b0cc696af98d1
    PATCHES fix-encoding.patch fix-sysctl.patch
)

configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unicode     IRR_UNICODE_PATH
        fast-fpu    IRR_FAST_MATH
        tools       IRR_BUILD_TOOLS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS 
        -DIRR_SHARED_LIB=${SHARED_LIB}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/irrlicht/)
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/irrlicht/irrlicht-config.cmake "include(\${CMAKE_CURRENT_LIST_DIR}/irrlicht-targets.cmake)")

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/irrlicht)
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

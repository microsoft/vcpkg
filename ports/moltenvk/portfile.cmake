vcpkg_fail_port_install(ON_TARGET "WINDOWS" "LINUX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/MoltenVK
    REF ce85a96d8041b208e6f32898912b217957019b5a
    SHA512 fa77a807a6e17fa7359b13546d46e5c5ebb4b7180df0a6fe378ff407c71c40670417ce135195db452df0d2fd1eaa51e39dda6743a1bbf19a6a68417d5e18e360
    HEAD_REF master
)

foreach (BUILD_TYPE "Debug" "Release")
    # Copy source
    if (BUILD_TYPE STREQUAL "Debug")
        set(BUILD_DIR_POSTFIX dbg)
        set(PACKAGE_DIR ${CURRENT_PACKAGES_DIR}/debug)
    else()
        set(BUILD_DIR_POSTFIX rel)
        set(PACKAGE_DIR ${CURRENT_PACKAGES_DIR})
    endif()
    set(BUILD_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_DIR_POSTFIX})
    file(MAKE_DIRECTORY ${BUILD_DIRECTORY})
    file(COPY "${SOURCE_PATH}/" DESTINATION "${BUILD_DIRECTORY}")
    
    # Build project
    set(MOLTENVK_BUILD_COMMAND "xcodebuild build -quiet -project MoltenVKPackaging.xcodeproj -scheme \"MoltenVK Package (macOS only)\" -configuration \"${BUILD_TYPE}\"")
    vcpkg_execute_build_process(
        COMMAND ${MOLTENVK_BUILD_COMMAND}
        WORKING_DIRECTORY ${BUILD_DIRECTORY}
        LOGNAME build-${PORT}-${BUILD_DIR_POSTFIX}
    )
    
    # copy MoltenVK include
    file(INSTALL ${BUILD_DIRECTORY}/Package/Latest/MoltenVK/include DESTINATION ${PACKAGE_DIR})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/vulkan)

    # copy MoltenVKShaderConverter include
    file(INSTALL ${BUILD_DIRECTORY}/Package/Latest/MoltenVKShaderConverter/include DESTINATION ${PACKAGE_DIR})
    
    # copy tools
    file(INSTALL ${BUILD_DIRECTORY}/Package/Latest/MoltenVKShaderConverter/Tools/MoltenVKShaderConverter DESTINATION ${PACKAGE_DIR}/tools/moltenvk)
    
    if(VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # copy dynamic library
        file(INSTALL ${BUILD_DIRECTORY}/Package/Latest/MoltenVK/dylib/macOS/libMoltenVK.dylib DESTINATION ${PACKAGE_DIR}/bin)
    endif()
    
    # copy static libraries
    file(INSTALL ${BUILD_DIRECTORY}/Package/Latest/MoltenVK/MoltenVK.xcframework/macos-x86_64/libMoltenVK.a DESTINATION ${PACKAGE_DIR}/lib)
    file(INSTALL ${BUILD_DIRECTORY}/Package/Latest/MoltenVKShaderConverter/MoltenVKShaderConverter.xcframework/macos-x86_64/libMoltenVKShaderConverter.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# copy copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/moltenvk RENAME copyright)
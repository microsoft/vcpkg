vcpkg_fail_port_install(ON_TARGET "WINDOWS" "LINUX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/MoltenVK
    REF ce85a96d8041b208e6f32898912b217957019b5a
    SHA512 fa77a807a6e17fa7359b13546d46e5c5ebb4b7180df0a6fe378ff407c71c40670417ce135195db452df0d2fd1eaa51e39dda6743a1bbf19a6a68417d5e18e360
    HEAD_REF master
	PATCHES
    	added_configure.patch
)

# TODO: The dependencies are manually pulled by this script. This step should be ommited and dependencies integrated by vcpkg.
vcpkg_execute_required_process(
    COMMAND ./fetchDependencies --macos
    WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
 	#SKIP_CONFIGURE this doesn't work. We therefore patch in an empty configure file
    COPY_SOURCE
    PREFER_NINJA
)

# TODO: This actually builds the release build two times. We need to actually build a debug verion
# TODO: Currently only macos target is built. ios and tv os should be exported as features
vcpkg_build_make(BUILD_TARGET macos)


# copy copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/moltenvk RENAME copyright)

# copy MoltenVK include
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Package/Latest/MoltenVK/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/vulkan)

# copy MoltenVKShaderConverter include
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Package/Latest/MoltenVKShaderConverter/include DESTINATION ${CURRENT_PACKAGES_DIR})

# copy tools
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Package/Latest/MoltenVKShaderConverter/Tools/MoltenVKShaderConverter DESTINATION ${CURRENT_PACKAGES_DIR}/tools/moltenvk)


if(VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # copy release dynamic
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Package/Latest/MoltenVK/dylib/macOS/libMoltenVK.dylib DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    # copy debug dynamic
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Package/Latest/MoltenVK/dylib/macOS/libMoltenVK.dylib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# copy release static
if (NOT VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Package/Latest/MoltenVK/MoltenVK.xcframework/macos-x86_64/libMoltenVK.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Package/Latest/MoltenVKShaderConverter/MoltenVKShaderConverter.xcframework/macos-x86_64/libMoltenVKShaderConverter.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    # copy debug static
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Package/Latest/MoltenVK/MoltenVK.xcframework/macos-x86_64/libMoltenVK.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Package/Latest/MoltenVKShaderConverter/MoltenVKShaderConverter.xcframework/macos-x86_64/libMoltenVKShaderConverter.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

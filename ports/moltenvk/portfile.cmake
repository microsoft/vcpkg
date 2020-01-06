vcpkg_fail_port_install(ON_TARGET "WINDOWS" "LINUX" "UWP")

set(BASH /bin/bash)
set(MAKE /usr/bin/make)


# change following flags to debug the port file
# as some steps are very very long to proceed.

set(PORT_REL_DOCLEAN true)
set(PORT_REL_DOBUILD true)
set(PORT_REL_DOINSTALL true)

set(PORT_DBG_DOCLEAN true)
set(PORT_DBG_DOBUILD true)
set(PORT_DBG_DOINSTALL true)


# Secure a correct build from version v1.0.38
# A contributor can manually update the port and CONTROL files to a higher version
# after running some local build tests with more recent updates.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/MoltenVK
    REF bf3ffff4bb2496e2dfa300bf5d869de95e5bc372
    SHA512 de876afd8420d7bab8236260f9a5b107f9c1b377210861d38ac3e23a8e6482d5e6aaf816720953e0f322c1f7c7843e00be8b8e49f5eaf4773a3e3f11b0d61e73
    HEAD_REF master
)


macro (copy_file) # src_file dst_dir [dst_name]
	if (${ARGC} EQUAL 3)
		file(COPY ${ARGV0} DESTINATION ${ARGV1})
		get_filename_component(_NAME ${ARGV0} NAME)
		file(RENAME ${ARGV1}/${_NAME} ${ARGV1}/${ARGV2})
	elseif(${ARGC} EQUAL 2)
		file(COPY ${ARGV0} DESTINATION ${ARGV1})
	else()
		message(FATAL_ERROR "copy_file requires at least 2 args")
	endif()
endmacro()


function (install_component_framework_and_lib FROM_DIR TO_DIR)
	get_filename_component(name ${FROM_DIR} NAME_WE)

    file(REMOVE_RECURSE ${TO_DIR}/${name}_ios.framework)
    file(REMOVE_RECURSE ${TO_DIR}/${name}_macos.framework)
	copy_file(${FROM_DIR}/iOS/framework/${name}.framework ${TO_DIR} ${name}_ios.framework)
	copy_file(${FROM_DIR}/macOS/framework/${name}.framework ${TO_DIR} ${name}_macos.framework)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	    copy_file(${FROM_DIR}/iOS/static/lib${name}.dylib ${TO_DIR}/lib lib${name}_ios.dylib)
	    copy_file(${FROM_DIR}/macOS/static/lib${name}.dylib ${TO_DIR}/lib lib${name}_macos.dylib)
	else()
	    copy_file(${FROM_DIR}/iOS/static/lib${name}.a ${TO_DIR}/lib lib${name}_ios.a)
	    copy_file(${FROM_DIR}/macOS/static/lib${name}.a ${TO_DIR}/lib lib${name}_macos.a)
	endif()
endfunction()


#
# release

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
    message(STATUS "Building for Release")

	get_filename_component(SOURCE_NAME ${SOURCE_PATH} NAME)
	set(BUILD_TRIPLET "${TARGET_TRIPLET}-rel")
	set(BUILD_ROOT "${CURRENT_BUILDTREES_DIR}/src-${BUILD_TRIPLET}")
	set(BUILD_DIR "${BUILD_ROOT}/${SOURCE_NAME}")

	if (PORT_REL_DOCLEAN)
	    message(STATUS " [1/4] Cloning source files ...")
		file(REMOVE_RECURSE ${BUILD_DIR})
    	file(COPY ${SOURCE_PATH} DESTINATION ${BUILD_ROOT})

	    message(STATUS " [2/4] Fetching dependencies (this step really takes a while) ...")
	    vcpkg_execute_required_process(
	        COMMAND ${BASH} fetchDependencies
	        WORKING_DIRECTORY ${BUILD_DIR}
	        LOGNAME fetch-dependencies-${BUILD_TRIPLET}
	    )
 	endif()

	if (PORT_REL_DOBUILD)
	    message(STATUS " [3/4] Building ...")
	    vcpkg_execute_required_process(
	        COMMAND xcodebuild -project MoltenVKPackaging.xcodeproj -scheme "MoltenVK Package"
	        WORKING_DIRECTORY ${BUILD_DIR}
	        LOGNAME xcodebuild-${BUILD_TRIPLET}
	    )
	endif()

	if (PORT_REL_DOINSTALL)
	    message(STATUS " [4/4] Installing ...")	    
	    copy_file(
	    	${BUILD_DIR}/Package/Latest/MoltenVK/include
	    	${CURRENT_INSTALLED_DIR})

	    copy_file(
	    	${BUILD_DIR}/Package/Latest/MoltenVK/include
	    	${CURRENT_PACKAGES_DIR})

	    copy_file(
	    	${BUILD_DIR}/Package/Latest/MoltenVKShaderConverter/include
	    	${CURRENT_INSTALLED_DIR})

	    copy_file(
	    	${BUILD_DIR}/Package/Latest/MoltenVKShaderConverter/include
	    	${CURRENT_INSTALLED_DIR})

	    copy_file(
	    	${BUILD_DIR}/Package/Latest/MoltenVKShaderConverter/Tools/MoltenVKShaderConverter
	    	${CURRENT_INSTALLED_DIR}/tools/moltenvk)

	    copy_file(
	    	${BUILD_DIR}/LICENSE
	    	${CURRENT_INSTALLED_DIR}/share/moltenvk
	    	LICENSE)

	    copy_file(
	    	${BUILD_DIR}/README.md
	    	${CURRENT_INSTALLED_DIR}/share/moltenvk)

	    copy_file(
	    	${BUILD_DIR}/CODE_OF_CONDUCT.md
	    	${CURRENT_INSTALLED_DIR}/share/moltenvk)

	    copy_file(
	    	${BUILD_DIR}/Package/Latest/LICENSE
	    	${CURRENT_PACKAGES_DIR}/share/moltenvk
	    	copyright)

	    install_component_framework_and_lib(
	    	${BUILD_DIR}/Package/Latest/MoltenVK
	    	${CURRENT_INSTALLED_DIR})
	    
	    install_component_framework_and_lib(
	    	${BUILD_DIR}/Package/Latest/MoltenVKShaderConverter/MoltenVKGLSLToSPIRVConverter
	    	${CURRENT_INSTALLED_DIR})

	    install_component_framework_and_lib(
	    	${BUILD_DIR}/Package/Latest/MoltenVKShaderConverter/MoltenVKSPIRVToMSLConverter
	    	${CURRENT_INSTALLED_DIR})
	endif()

    message(STATUS " Done.")
endif()


#
# debug

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    message(STATUS "Building for Debug")

	get_filename_component(SOURCE_NAME ${SOURCE_PATH} NAME)
	set(BUILD_TRIPLET "${TARGET_TRIPLET}-dbg")
	set(BUILD_ROOT "${CURRENT_BUILDTREES_DIR}/src-${BUILD_TRIPLET}")
	set(BUILD_DIR "${BUILD_ROOT}/${SOURCE_NAME}")

	if (PORT_DBG_DOCLEAN)
	    message(STATUS " [1/4] Cloning source files ...")
		file(REMOVE_RECURSE ${BUILD_DIR})
    	file(COPY ${SOURCE_PATH} DESTINATION ${BUILD_ROOT})

	    message(STATUS " [2/4] Fetching dependencies (this step really takes a while) ...")
	    vcpkg_execute_required_process(
	        COMMAND ${BASH} fetchDependencies
	        WORKING_DIRECTORY ${BUILD_DIR}
	        LOGNAME fetch-dependencies-${BUILD_TRIPLET}
	    )
 	endif()

	if (PORT_DBG_DOBUILD)
	    message(STATUS " [3/4] Building ...")
	    vcpkg_execute_required_process(
	        COMMAND xcodebuild -project MoltenVKPackaging.xcodeproj -scheme "MoltenVK Package (Debug)"
	        WORKING_DIRECTORY ${BUILD_DIR}
	        LOGNAME xcodebuild-${BUILD_TRIPLET}
	    )
	endif()

	if (PORT_DBG_DOINSTALL)
	    message(STATUS " [4/4] Installing ...")
	    install_component_framework_and_lib(
	    	${BUILD_DIR}/Package/Latest/MoltenVK
	    	${CURRENT_INSTALLED_DIR}/debug)
	    
	    install_component_framework_and_lib(
	    	${BUILD_DIR}/Package/Latest/MoltenVKShaderConverter/MoltenVKGLSLToSPIRVConverter
	    	${CURRENT_INSTALLED_DIR}/debug)

	    install_component_framework_and_lib(
	    	${BUILD_DIR}/Package/Latest/MoltenVKShaderConverter/MoltenVKSPIRVToMSLConverter
	    	${CURRENT_INSTALLED_DIR}/debug)
	endif()

    message(STATUS " Done.")
endif()


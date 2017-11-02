include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/aws-sdk-cpp
    REF 1.2.4
    SHA512 dc96e40fe72e4b115607245f536cd13414e33a8f754153fd137f1391af14b9793fc8a07f9f984490e0783e385c2c7b9a421878b63ea793012f53fefe7ec4d368
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
		${CMAKE_CURRENT_LIST_DIR}/drop_git.patch
		${CMAKE_CURRENT_LIST_DIR}/disable_warning_as_error.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
	set(FORCE_SHARED_CRT OFF)
else()
	set(FORCE_SHARED_CRT ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DENABLE_TESTING=OFF
		-DFORCE_SHARED_CRT=${FORCE_SHARED_CRT}
)

vcpkg_install_cmake()

file(GLOB CMAKE_FILES ${CURRENT_PACKAGES_DIR}/lib/cmake/*)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)

file(COPY ${CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share)

vcpkg_copy_pdbs()

file(GLOB AWS_TARGETS "${CURRENT_PACKAGES_DIR}/share/aws-cpp-sdk-*/aws-cpp-sdk-*targets.cmake")
foreach(AWS_TARGETS ${AWS_TARGETS})
    file(READ ${AWS_TARGETS} _contents)
    string(REGEX REPLACE
        "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
        "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
        _contents "${_contents}")
    file(WRITE ${AWS_TARGETS} "${_contents}")
endforeach()

file(GLOB AWS_TARGETS_RELEASE "${CURRENT_PACKAGES_DIR}/share/aws-cpp-sdk-*/aws-cpp-sdk-*targets-release.cmake")
foreach(AWS_TARGETS_RELEASE ${AWS_TARGETS_RELEASE})
    file(READ ${AWS_TARGETS_RELEASE} _contents)
    string(REGEX REPLACE
        "bin\\/([A-Za-z0-9_.-]+lib)"
        "lib/\\1"
        _contents "${_contents}")
    file(WRITE ${AWS_TARGETS_RELEASE} "${_contents}")
endforeach()

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/lib/cmake
	${CURRENT_PACKAGES_DIR}/lib/pkgconfig
	${CURRENT_PACKAGES_DIR}/debug/lib/cmake
	${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
	${CURRENT_PACKAGES_DIR}/nuget
	${CURRENT_PACKAGES_DIR}/debug/nuget)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(GLOB LIB_FILES          ${CURRENT_PACKAGES_DIR}/bin/*.lib)
	file(GLOB DEBUG_LIB_FILES    ${CURRENT_PACKAGES_DIR}/debug/bin/*.lib)
	file(COPY ${LIB_FILES}       DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
	file(COPY ${DEBUG_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
	file(REMOVE ${LIB_FILES} ${DEBUG_LIB_FILES})
	
	file(APPEND ${CURRENT_PACKAGES_DIR}/include/aws/core/SDKConfig.h "#define USE_IMPORT_EXPORT")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-sdk-cpp RENAME copyright)

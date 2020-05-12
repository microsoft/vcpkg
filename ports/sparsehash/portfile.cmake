include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparsehash/sparsehash
    REF sparsehash-2.0.3
    SHA512 bb00d0acb8eba65f7da8015ea4f6bebf8bba36ed6777881960ee215f22b7be17b069c59838d210551ce67a34baccfc7b2fed603677ec53c0c32714d8e76f5d6c
    HEAD_REF master
    PATCHES 00001-windows-use-std.patch
)

if(VCPKG_TARGET_IS_WINDOWS)

	file(COPY ${SOURCE_PATH}/src/google DESTINATION ${CURRENT_PACKAGES_DIR}/include)
	file(COPY ${SOURCE_PATH}/src/sparsehash DESTINATION ${CURRENT_PACKAGES_DIR}/include)
	file(COPY ${SOURCE_PATH}/src/windows/sparsehash/internal/sparseconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/sparsehash/internal)

else()

	vcpkg_execute_required_process(
		COMMAND ${SOURCE_PATH}/configure ${OPTIONS} --prefix=${CURRENT_PACKAGES_DIR}
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME configure-${TARGET_TRIPLET}
	)

	vcpkg_execute_required_process(
		COMMAND make -j ${VCPKG_CONCURRENCY} install
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME install-${TARGET_TRIPLET}
	)

endif()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in 
    ${CURRENT_PACKAGES_DIR}/share/sparsehash/sparsehash-config.cmake 
    @ONLY
)

configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/sparsehash/copyright COPYONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/sparsehash)

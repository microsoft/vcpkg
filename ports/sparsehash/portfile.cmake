vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparsehash/sparsehash
    REF sparsehash-2.0.4
    SHA512 40C007BC5814DD5F2BDACD5EC884BC5424F7126F182D4C7B34371F88B674456FC193B947FDD283DBD0C7EB044D8F06BAF8CAEC6C93E73B1B587282B9026EA877
    HEAD_REF master
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

vcpkg_fixup_pkgconfig()

vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.com/inivation
        OUT_SOURCE_PATH SOURCE_PATH
        REPO dv/dv-processing
        REF 96d082a862bb1e5bfdc79b39aa09e7a50c2dac49
        SHA512 cf74e8a6f94f690e159778b59eb2e4d9c8f51f09437e94a507a2ec8f42e167fe6d1413ba91ab608624a02b4b479b27f454e7b7792d125ce5a163f4aa98e774cc
        HEAD_REF rel_1.5
)

vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.com/inivation
        OUT_SOURCE_PATH CMAKEMOD_SOURCE_PATH
        REPO dv/cmakemod
        REF a4d7eccfdc5f83e399786a77df79b178b762858b
        SHA512 4fe9cc5099ab8b41c982df45cbf9a000b2cb1f1c6ed536685943a60520cff49e262ec43af8187177c50a0df2dfca57e7861bf2e7d07834fc16e85c30eb9a9edb
        HEAD_REF a4d7eccfdc5f83e399786a77df79b178b762858b
)

file(GLOB CMAKEMOD_FILES ${CMAKEMOD_SOURCE_PATH}/*)
file(COPY ${CMAKEMOD_FILES} DESTINATION ${SOURCE_PATH}/cmakemod)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
	        -DENABLE_TESTS=OFF
		-DENABLE_SAMPLES=OFF
		-DENABLE_PYTHON=OFF
		-DENABLE_UTILITIES=OFF
		-DBUILD_CONFIG_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "dv-processing" CONFIG_PATH "share/dv-processing")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if (VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
else()
        vcpkg_fixup_pkgconfig()
endif()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

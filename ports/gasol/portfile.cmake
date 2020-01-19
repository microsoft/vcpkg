vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "arm" "arm64")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PytLab/GASol
    REF 05af009bca2903c1cc491c9a6eed01bc3c936637
    SHA512 a8546bf565a389b919dd1dd5b88b4985c1803cbb09fab0715d1b0abfda92a6bf3adea7e4b3329ad82a6f6892f1747a73a632687fd79fb77c937e7ba07c62268a
    HEAD_REF master
    PATCHES
	   gasol.patch
)

file(MAKE_DIRECTORY ${SOURCE_PATH}/build)
vcpkg_execute_required_process(
		COMMAND cmake ..
		WORKING_DIRECTORY ${SOURCE_PATH}/build
		LOGNAME cmake-${TARGET_TRIPLET}
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
if (UNIX)
    vcpkg_execute_required_process(
		COMMAND make
		WORKING_DIRECTORY ${SOURCE_PATH}/build
		LOGNAME make-${TARGET_TRIPLET}
    )
    file(COPY ${SOURCE_PATH}/build/src/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN *.a)
else ()
    set(VS_PLATFORM ${VCPKG_TARGET_ARCHITECTURE})
    if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)
        set(VS_PLATFORM "Win32")
    endif()
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/build/GASol.sln
        TARGET gasol
        PLATFORM ${VS_PLATFORM}
        USE_VCPKG_INTEGRATION
    )
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/build/src/Debug/GASol.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/build/src/Debug/GASol.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${SOURCE_PATH}/build/src/Debug/GASol.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/src/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/CMakeFiles)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/Debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/Release)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/GASol.dir)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gasol RENAME copyright)

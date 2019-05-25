include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artyom-beilis/cppcms
    REF b72b19915794d1af63c9a9e9bea58e20a4ad93d4
	SHA512 ed212a8ae18d8a356f3bb9e64f2108a8f1209ff0d7ebf57bd1ef6e8e766fe47d00833a012e19b80db6a07732b3785689d6f4d01546b8053bdfcec0463e0a128c
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR ${PYTHON2} DIRECTORY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS -DCMAKE_PROGRAM_PATH=${PYTHON2_DIR} -DUSE_WINDOWS6_API=ON
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB EXE_DEBUG_FILES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${EXE_DEBUG_FILES})
file(GLOB EXE_FILES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(REMOVE ${EXE_FILES})

# Handle copyright
file(COPY ${SOURCE_PATH}/LGPLv3.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppcms)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppcms/LGPLv3.txt ${CURRENT_PACKAGES_DIR}/share/cppcms/copyright)

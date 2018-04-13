include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "cppcms doesn't support static linkage. Building dynamic instead.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "cppcms doesn't support static CRT linkage.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artyom-beilis/cppcms
    REF v1.1.0
	SHA512 cfc77f28ddee05b8a350fff1dbd7c09adcf008b8662d4f977b203dee50b5fadae97df499a655ebb48263a7448e0bdca514c8ac52ea805bf33e48612dabaa69f4
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

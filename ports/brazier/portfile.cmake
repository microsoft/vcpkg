set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/brazierConfig.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/brazier")

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON BRAZIER_VERSION GET "${_vcpkg_json}" "version")

file(READ "${CMAKE_CURRENT_LIST_DIR}/brazierConfigVersion.cmake.in" _ver_template)
string(REPLACE "@VERSION@" "${BRAZIER_VERSION}" _ver_content "${_ver_template}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/brazier/brazierConfigVersion.cmake"
     "${_ver_content}")

file(GLOB LICENSE_FILES
    "${CMAKE_CURRENT_LIST_DIR}/LICENSE*"
    "${CMAKE_CURRENT_LIST_DIR}/COPYING*"
    "${CMAKE_CURRENT_LIST_DIR}/LGPL*.txt"
    "${CMAKE_CURRENT_LIST_DIR}/GPL*.txt"
)

if(NOT LICENSE_FILES)
    message(FATAL_ERROR
        "brazier: no license files found in ${CMAKE_CURRENT_LIST_DIR}")
endif()

vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/available")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/available/README.txt" [[
This directory contains files which can enable certain tests
when copied to `../available/`.
]])
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/enabled")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/enabled/README.txt" [[
This directory contains files which enable certain tests.
]])

foreach(module IN ITEMS "current-cmake" "minimum-cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/${module}.cmake")
    if(COMMAND z_vcpkg_maintainer_options_test_${module})
        cmake_language(CALL z_vcpkg_maintainer_options_test_${module})
    endif()
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${module}.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/available")
    if("${module}" IN_LIST FEATURES)
        file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${module}.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/enabled")
    endif()
endforeach()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

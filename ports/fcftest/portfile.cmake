vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fcf-framework/fcfTest
    REF "v1.2.6"
    SHA512 c683da73a48eb79da8851f2545e9dbca6b52e99206871caeaf8fd59b260a44885843c76ab49f07b21bd751ab9ec15828a894ce044d2393b04999b08247d9cb92
)

file(INSTALL "${SOURCE_PATH}/test.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fcfTest")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/fcftest/fcftestConfig.cmake" "
  if(NOT TARGET fcf::fcfTest)
    add_library(fcf::fcfTest INTERFACE IMPORTED)
    set_target_properties(fcf::fcfTest PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
    )
  endif()
")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")


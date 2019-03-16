#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO svgpp/rapidxml_ns
  REF 04674e33e3bbfeee05875a29a36734667c0f3cfd
  SHA512 c82d55ca7ec358427f811689604ba02582de9d7f57d0caa3a96e2c36b9f3751e9acefc6f84348e6c619dacca31880f279bf9d9959f8eff251f3d3276c836bcd2
  HEAD_REF master
)

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidxml-ns)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidxml-ns/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidxml-ns/copyright)

# Copy the header files
file(INSTALL 
	     ${SOURCE_PATH}/rapidxml_ns.hpp
	     ${SOURCE_PATH}/rapidxml_ns_print.hpp
	     ${SOURCE_PATH}/rapidxml_ns_utils.hpp
	 DESTINATION 
	     ${CURRENT_PACKAGES_DIR}/include/rapidxml-ns)

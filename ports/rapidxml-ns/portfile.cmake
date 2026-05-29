#header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO svgpp/rapidxml_ns
  REF v1.13.2
  SHA512 72cdd7e728471e8903ce64470f5172abe7f2300d4d115b3a27b4d4ffb3c20e59aefb9b23c535e37baa3f53c9125aa2932d6fa9ba24e658151e1c9b12f959523a
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

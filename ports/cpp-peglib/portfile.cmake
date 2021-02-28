#header-only library
vcpkg_from_github(
	    OUT_SOURCE_PATH SOURCE_PATH
      	    REPO yhirose/cpp-peglib
	    REF v0.1.0
	    SHA512 7efe9da8fe75d766a50d6508c81369b71981aa1e36c0d9981d57b75822fde81074b8803753bfa599ab4ce2a7047be731c22476d0938728ebb9a9dbf63aaeb9e6
	    HEAD_REF master
	    )

    	    file(COPY ${SOURCE_PATH}/peglib.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
	    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
	    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

	    # Handle copyright
	    file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpp-peglib)
	    file(RENAME ${CURRENT_PACKAGES_DIR}/share/cpp-peglib/LICENSE ${CURRENT_PACKAGES_DIR}/share/cpp-peglib/copyright)

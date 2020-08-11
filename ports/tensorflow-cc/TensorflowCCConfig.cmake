set(tensorflow_cc_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../include")

message(WARNING "Tensorflow has vendored dependencies. You may need to manually include files from tensorflow-external")
set(tensorflow_cc_INCLUDE_DIRS
	${tensorflow_cc_INCLUDE_DIR}
	${tensorflow_cc_INCLUDE_DIR}/tensorflow-external/
	${tensorflow_cc_INCLUDE_DIR}/tensorflow-external/tensorflow/
	${tensorflow_cc_INCLUDE_DIR}/tensorflow-external/external/com_google_absl
	${tensorflow_cc_INCLUDE_DIR}/tensorflow-external/bazel-out/k8-opt/bin/
	${tensorflow_cc_INCLUDE_DIR}/tensorflow-external/external/protobuf_archive/src/
)

if(CMAKE_HOST_WIN32)
	if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		add_library(tensorflow_cc::tensorflow_cc SHARED IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_cc
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../bin/tensorflow.dll
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
	else()
		add_library(tensorflow_cc::tensorflow_cc STATIC IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_cc
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/tensorflow.lib
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
	endif()
	set(tensorflow_cc_FOUND TRUE)
elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
	if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		add_library(tensorflow_cc::tensorflow_cc SHARED IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_cc
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow.1.14.0.dylib
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
		add_library(tensorflow_cc::tensorflow_framework SHARED IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_framework
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow_framework.1.14.0.dylib
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
	else()
		add_library(tensorflow_cc::tensorflow_cc STATIC IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_cc
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow.1.14.0.a
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
		add_library(tensorflow_cc::tensorflow_framework STATIC IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_framework
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow_framework.1.14.0.a
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
	endif()
	set(tensorflow_cc_FOUND TRUE)
	set(tensorflow_framework_FOUND TRUE)
else()
	if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		add_library(tensorflow_cc::tensorflow_cc SHARED IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_cc
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow.so.1.14.0
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
		add_library(tensorflow_cc::tensorflow_framework SHARED IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_framework
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow_framework.so.1.14.0
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
	else()
		add_library(tensorflow_cc::tensorflow_cc STATIC IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_cc
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow.a.1.14.0
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
		add_library(tensorflow_cc::tensorflow_framework STATIC IMPORTED)
		set_target_properties(tensorflow_cc::tensorflow_framework
			PROPERTIES
			IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow_framework.a.1.14.0
			INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
		)
	endif()
	set(tensorflow_cc_FOUND TRUE)
	set(tensorflow_framework_FOUND TRUE)
endif()

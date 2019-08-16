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

add_library(tensorflow_cc::tensorflow_framework SHARED IMPORTED)
set_target_properties(tensorflow_cc::tensorflow_framework 
	PROPERTIES
	IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow_framework.so.1.14.0
	INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
)

add_library(tensorflow_cc::tensorflow_cc SHARED IMPORTED)
set_target_properties(tensorflow_cc::tensorflow_cc
	PROPERTIES 
	IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/../../lib/libtensorflow_cc.so.1.14.0
	INTERFACE_INCLUDE_DIRECTORIES "${tensorflow_cc_INCLUDE_DIRS}"
)

set(tensorflow_cc_FOUND TRUE)
set(tensorflow_framework_FOUND TRUE)
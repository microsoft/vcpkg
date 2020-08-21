message(WARNING "Tensorflow has vendored dependencies. You may need to manually include files from tensorflow-external")

add_library(tensorflow_cc::tensorflow_cc SHARED IMPORTED)
set_target_properties(tensorflow_cc::tensorflow_cc
	PROPERTIES
	IMPORTED_LOCATION "${VCPKG_INSTALLATION_ROOT}/installed/${TARGET_TRIPLET}/bin/tensorflow.dll"
	IMPORTED_IMPLIB "${VCPKG_INSTALLATION_ROOT}/installed/${TARGET_TRIPLET}/bin/tensorflow.lib"
	INTERFACE_INCLUDE_DIRECTORIES "${VCPKG_INSTALLATION_ROOT}/installed/${TARGET_TRIPLET}/include/tensorflow-external"
)
set(tensorflow_cc_FOUND TRUE)

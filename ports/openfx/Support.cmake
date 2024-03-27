add_library(OfxSupport STATIC
    Library/ofxsCore.cpp
    Library/ofxsImageEffect.cpp
    Library/ofxsInteract.cpp
    Library/ofxsLog.cpp
    Library/ofxsMultiThread.cpp
    Library/ofxsParams.cpp
    Library/ofxsProperty.cpp
    Library/ofxsPropertyValidation.cpp
)

set(OFX_SUPPORT_HEADERS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include CACHE INTERNAL "OFX_SUPPORT_HEADERS_DIR")
target_include_directories(OfxSupport
    PUBLIC
    $<BUILD_INTERFACE:${OFX_SUPPORT_HEADERS_DIR}>
    $<INSTALL_INTERFACE:include>
)

target_link_libraries(OfxSupport PUBLIC OpenFx)

target_compile_features(OfxSupport PUBLIC cxx_std_11)

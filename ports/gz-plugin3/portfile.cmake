set(PACKAGE_NAME plugin)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 9355eb9ec7bb6dffaadcd37009d16db215b7def6a835ba4704d6c6831c9253b2abf40f6ad01fe70609e46c6f121adc80f809e80c8168c795511434c118c12b10
   OPTIONS 
   PATCHES
)

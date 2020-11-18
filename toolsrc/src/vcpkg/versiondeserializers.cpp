#include <vcpkg/versiondeserializers.h>

using namespace vcpkg;

VersionTDeserializer VersionTDeserializer::instance;
BaselineDeserializer BaselineDeserializer::instance;
VersionDbEntryDeserializer VersionDbEntryDeserializer::instance;
VersionDbEntryArrayDeserializer VersionDbEntryArrayDeserializer::instance;

Json::StringDeserializer VersionTDeserializer::version_deserializer{"version"};

#include <dcmtk/dcmdata/dcjson.h>
#include <dcmtk/dcmtls/tlslayer.h>

int main()
{
  auto djfp = DcmJsonFormatPretty(OFTrue);
  DcmTLSTransportLayer::initializeOpenSSL();  // https://github.com/microsoft/vcpkg/issues/38476
  return 0;
}

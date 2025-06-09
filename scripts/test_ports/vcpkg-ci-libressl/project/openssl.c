#include <openssl/ssl.h>

#if OPENSSL_VERSION_NUMBER != 0x20000000L
#  error Unexpected version
#endif

int main()
{
  return SSL_library_init();
}

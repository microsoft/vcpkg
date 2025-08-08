#include <libheif/heif.h>

int main()
{
    heif_context* ctx = heif_context_alloc();
    heif_context_free(ctx);
    return 0;
}

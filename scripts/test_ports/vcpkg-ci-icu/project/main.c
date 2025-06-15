#include "unicode/udat.h"

int main()
{
    UErrorCode status = U_ZERO_ERROR;
    UDateFormat* dateFormatter = udat_open(UDAT_NONE, UDAT_SHORT, NULL, NULL, -1, NULL, 0, &status);
    udat_close(dateFormatter);
    return 0;
}

/* Cf. https://netlib.org/lapack/lapacke.html */
#include <lapacke.h>

int main()
{
    double a[5][3] = {1,1,1,2,3,4,3,5,2,4,2,5,5,4,3};
    double b[5][2] = {-10,-3,12,14,14,12,16,16,18,16};

    lapack_int m = 5;
    lapack_int n = 3;
    lapack_int nrhs = 2;
    lapack_int lda = 3;
    lapack_int ldb = 2;

    lapack_int info = LAPACKE_dgels(LAPACK_ROW_MAJOR,'N',m,n,nrhs,*a,lda,*b,ldb);

    return 0;
}

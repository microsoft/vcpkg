extern void dgemm_(char*, char*, int*, int*,int*, double*, double*, int*, double*, int*, double*, double*, int*);

int main()
{
    char ta = 'N';
    char tb = 'N';
    int m = 2;
    int n = 2;
    int k = 1;
    double alpha = 0.5;
    double A[2] = {1.0, 2.0};  // m x k
    double B[2] = {3.0, 4.0};  // k x n
    double beta = 0.05;
    double C[4] = {100.0, 200.0, 300.0, 400.0};  // 2 x 2
    dgemm_(&ta, &tb, &m, &n, &k, &alpha, A, &m, B, &k, &beta, C, &m);
    return 0;
}

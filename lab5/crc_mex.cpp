#define CRC_NO_MAIN
#include "crc.cpp"
#include "mex.h"
#include <chrono>
#include <vector>

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
    if (nrhs != 3) {
        mexErrMsgTxt("USAGE: times_us = crc_mex(N, G, runs)");
    }

    int N = (int)mxGetScalar(prhs[0]);
    char* g_cstr = mxArrayToString(prhs[1]);
    string G(g_cstr);
    mxFree(g_cstr);
    int runs = (int)mxGetScalar(prhs[2]);
    
    string zeros(G.size() - 1, '0');
    vector<string> inputs(64);
    for (int i = 0; i < 64; i++) {
        inputs[i] = generateData(N) + zeros;
    }

    plhs[0] = mxCreateDoubleMatrix(1, runs, mxREAL);
    double* times = mxGetPr(plhs[0]);

    volatile int sink = 0;
    
    for (int w = 0; w < 100; w++) {
        sink += calcCRC(inputs[w & 63], G)[0];
    }

    for (int r = 0; r < runs; r++) {
        auto t1 = chrono::steady_clock::now();
        string crc = calcCRC(inputs[r & 63], G);
        auto t2 = chrono::steady_clock::now();
        sink += crc[0];
        times[r] = chrono::duration<double, micro>(t2 - t1).count();
    }
}

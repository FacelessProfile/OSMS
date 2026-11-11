#include <iostream>
#include <vector>
#include <string>
#include <cmath>
#include <iomanip>

using namespace std;

const int N = 31;

// by scheme fb_x = x4 ^ x5, fb_y = y2 ^ y5, out = x5 ^ y5
int gold_tick(vector<int> &x, vector<int> &y) {
    int out = x[4] ^ y[4], bx = x[3] ^ x[4], by = y[1] ^ y[4];
    for (int i = 4; i > 0; --i) { x[i] = x[i - 1]; y[i] = y[i - 1]; }
    x[0] = bx; y[0] = by;
    return out;
}

// generate Gold's sequence of len len
vector<int> get_gold(vector<int> x, vector<int> y, int len = N) {
    vector<int> s(len);
    for (int i = 0; i < len; ++i) s[i] = gold_tick(x, y);
    return s;
}

// calculate correlation R = (M-D)/N
double calc_corr(const vector<int> &a, const vector<int> &b) {
    int m = 0, d = 0;
    for (size_t i = 0; i < a.size(); ++i) (a[i] == b[i]) ? m++ : d++;
    return (double)(m - d) / (int)a.size();
}

// cyclic shift in right direction
vector<int> shift_right(const vector<int> &s, int sh) {
    int n = s.size(); vector<int> r(n);
    for (int i = 0; i < n; ++i) r[(i + sh) % n] = s[i]; return r;
}

void print_seq(const vector<int> &s) {
    for (int b : s) cout << b;
    cout << "\n";
}

// check seq by 3 rules
void autocheck(const vector<int> &s) {
    int n = s.size(), n1 = 0, runs = 1;
    cout << "\n--- Check sequence (N = " << n << ") ---\n"; print_seq(s);
    for (int b : s) n1 += b;
    int n0 = n - n1, diff = abs(n1 - n0);
    cout << "1. Balance: zeros = " << n0 << ", ones = " << n1 
         << ", diff = " << diff << (diff <= 1 ? " [PASS]\n" : " [FAIL]\n");
    for (int i = 1; i < n; ++i) if (s[i] != s[i - 1]) runs++;
    if (s[0] == s[n - 1] && runs > 1) runs--;
    cout << "2. Cyclic runs: count = " << runs << (runs >= n / 2 ? " [PASS]\n" : " [FAIL]\n");
    bool two_level = true;
    cout << "3. Correlation (ACF tau 1..5): ";
    for (int t = 1; t <= min(n - 1, 5); ++t) {
        double r = calc_corr(s, shift_right(s, t));
        cout << fixed << setprecision(2) << r << " ";
        if (fabs(r - (-1.0 / n)) > 1e-3) two_level = false;
    }
    cout << "...\n   Two-level ACF (-1/N): " << (two_level ? "YES [PASS]\n" : "NO [FAIL]\n");
}

int main(int argc, char* argv[]) {
    // initial states for 25 var
    vector<int> x1 = {1, 1, 0, 0, 1}, y1 = {0, 0, 0, 0, 1}; // 25_10, 32 mod 31 = 1_10
    vector<int> seq1 = get_gold(x1, y1);
    cout << "Gold sequence 1:\n"; print_seq(seq1);

    cout << "\nAutocorrelation table:\nShift | Sequence                        | R\n";
    for (int t = 0; t <= N; ++t) {
        vector<int> sh = shift_right(seq1, t);
        cout << setw(5) << t << " | ";
        for (int b : sh) cout << b;
        cout << " | " << fixed << setprecision(2) << setw(5) << calc_corr(seq1, sh) << "\n";
    }

    // seq with modified polynomials: x2 = 26, y2 = 27
    vector<int> x2 = {1, 1, 0, 1, 0}, y2 = {1, 1, 0, 1, 1};
    vector<int> seq2 = get_gold(x2, y2);
    cout << "\nGold sequence 2:\n"; print_seq(seq2);
    cout << "Cross-correlation R12 = " << fixed << setprecision(2) << calc_corr(seq1, seq2) << "\n";

    autocheck(seq1);

    // input sequence check
    if (argc > 1) {
        string arg = argv[1]; vector<int> u;
        for (char c : arg) if (c == '0' || c == '1') u.push_back(c - '0');
        if (!u.empty()) autocheck(u);
    }
    return 0;
}

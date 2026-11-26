#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <cmath>


using namespace std;
const string POLY = "10001111";


// Packet GEN
string generateData(int len) {
    string data = "";
    for (int i = 0; i < len; i++) {
        data += (rand() % 2 == 0) ? '0' : '1';
    }
    return data;
}


// CRC CALC
string calcCRC(string bits, string G) {
    int n = G.size();
    for (int i = 0; i <= (int)bits.size() - n; i++) {
        if (bits[i] == '1') {
            for (int j = 0; j < n; j++) {
                bits[i + j] = (bits[i + j] == G[j]) ? '0' : '1';
            }
        }
    }
    return bits.substr(bits.size() - (n - 1));
}


// ERR check
bool hasError(string rem) {
    for (int i = 0; i < (int)rem.size(); i++) {
        if (rem[i] == '1') return true;
    }
    return false;
}


// AWGN overlaying
string addAWGN(string packet, double sigma) {
    string noisy = packet;
    for (int i=0; i < (int)packet.size(); i++) {
        double signal = (packet[i] == '1') ? 1.0:-1.0;
        double u1 = (rand()+1.0) / (RAND_MAX+1.0);
        double u2 = (rand()+1.0) / (RAND_MAX+1.0);
        double noise = sigma * sqrt(-2.0 * log(u1)) * cos(2.0 * 3.1415926535893238 * u2);
        noisy[i] = (signal+noise >= 0.0) ? '1':'0';
    }
    return noisy;
}


string transmitAndCheck(int N, string G) {
    int crcLen = G.size()-1;
    string data = generateData(N);
    string crc = calcCRC(data+string(crcLen,'0'), G);
    string packet = data+crc;
    string rem = calcCRC(packet, G);

    cout << "Data " << N << " bit: " << data << "\n";
    cout << "CRC " << crcLen << " bit: " << crc << "\n";
    cout << "Rx remainder: " << rem << " -> "
         << (hasError(rem) ? "ERROR" : "NO ERROR WAS DETECTED") << "\n\n";
    return packet;
}



#ifndef CRC_NO_MAIN
int main() {
    srand(time(0));

    string G = POLY;
    int N = 20 + 25;

    cout << "=== VAR 25 | poly = " << G
         << " | CRC_len = " << (G.size() - 1) << " ===\n\n";

    // 45 bit Packet test
    cout << "------- (N = " << N << " bit) --------\n";
    transmitAndCheck(N, G);
    
    cout << "----------- N = 250 bit -------------\n";
    string packet250 = transmitAndCheck(250, G);
    cout << "--- 1 bit distortion in " << packet250.size() << " bits) ---\n";
    
    int detected = 0, missed = 0;
    for (int i = 0; i < (int)packet250.size(); i++) {
        string broken = packet250;
        broken[i] = (broken[i] == '0') ? '1' : '0';
        if (hasError(calcCRC(broken, G))) detected++;
        else missed++;
    }
    
    cout << "checks: " << packet250.size()
         << " | detected: " <<  detected
         << " | missed: " <<   missed << "\n\n";

    
    // AWGN
    double sigma = 0.5;
    cout << "--- AWGN channel (sigma = " << sigma << ") ---\n";
    string noisy = addAWGN(packet250, sigma);
    
    int bitErrors = 0;
    for (int i = 0; i < (int)packet250.size(); i++) {
        if (noisy[i] != packet250[i]) bitErrors++;
    }


    string rem = calcCRC(noisy, G);
    cout << "Bit errors: " << bitErrors << "\n";
    cout << "CRC on rx:   " << rem << " -> "
         << (hasError(rem) ? "ERROR" : "NO ERROR WAS DETECTED") << "\n";


    return 0;
}
#endif

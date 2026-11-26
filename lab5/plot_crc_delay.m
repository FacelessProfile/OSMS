mex crc_mex.cpp;

crc_sizes = 1:32;
packet_bytes = [250, 1000];
runs = 10000;

delays = zeros(length(packet_bytes), length(crc_sizes));


rng(67);
for p = 1:length(packet_bytes)
    N_bits = packet_bytes(p) * 8;
    for k = crc_sizes
    
        if k == 1
            G = '11';
        else
            G = ['1', char('0' + randi([0 1], 1, k - 1)), '1'];
        end
        
        times_us = crc_mex(N_bits, G, runs);
        times_us = times_us(times_us > 0);
        delays(p, k) = exp(mean(log(times_us)));
        
    end
end


figure;
hold on;
grid on;


plot(crc_sizes, delays(1, :), '-o');
plot(crc_sizes, delays(2, :), '-s');
legend('250 B', '1000 B');


xlabel('CRC size (bits)');
ylabel('Processing delay (\mus)');
xlim([1 32]);
xticks([1 4 8 12 16 20 24 28 32]);

saveas(gcf, 'crc_delay.png');

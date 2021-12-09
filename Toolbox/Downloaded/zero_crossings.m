function ZX = zero_crossings(y)

% https://uk.mathworks.com/matlabcentral/answers/267222-easy-way-of-finding-zero-crossing-of-a-function

x = 1:length(y);
UpZCi = @(v) find(v(1:end-1) <= 0 & v(2:end) > 0);	% Returns Up Zero-Crossing Indices
DownZCi = @(v) find(v(1:end-1) >= 0 & v(2:end) < 0);    % Returns Down Zero-Crossing Indices
ZeroX = @(x0,y0,x1,y1) x0 - (y0.*(x0 - x1))./(y0 - y1); % Interpolated x value for Zero-Crossing 
ZXi = sort([UpZCi(y),DownZCi(y)]);

ZX = ZeroX(x(ZXi),y(ZXi),x(ZXi+1),y(ZXi+1));

% === Checking for zero at the ignored value ===
if y(end)==0
    ZX(end+1) = x(end);
end
% ==============================================
% figure(1)
% plot(x, y, '-b')
% hold on;
% plot(ZX,zeros(1,length(ZX)),'ro')
% grid on;
% legend('Signal', 'Interpolated Zero-Crossing')
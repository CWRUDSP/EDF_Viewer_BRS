% This function is to find the Poincare Parameters
% Inputs:
%           RR: RR Interval
%           tau: Delay
% Outputs:
%           SD1C
%           SD2C
%           SD_Ratio
%           CDOWN
%           CUP
% Developed By: Reza Jamasebi
function [SD1C SD2C SD_Ratio CDOWN CUP]=PoinCareFnct(x,y,tau)

L = length(x);
SD1C = sqrt((1/L)*sum(((x-y)-mean(x-y)).^2)/2);
SD2C = sqrt((1/L)*sum(((x + y) - mean(x + y)).^2)/2);
SD1I = sqrt((1/L) * (sum((x - y).^2)/2));
xy = (x - y)/sqrt(2);
indices_up = find(xy > 0);
indices_down = find(xy < 0);
SD1UP = sqrt(sum(xy(indices_up).^2)/L);
SD1DOWN = sqrt(sum(xy(indices_down).^2)/L);
CUP = SD1UP^2/SD1I^2;
CDOWN = SD1DOWN^2/SD1I^2;
SD_Ratio=SD1C/SD2C;
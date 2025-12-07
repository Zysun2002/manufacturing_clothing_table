% space division
%????????


if ~exist('Ret', 'var'); Ret=6; end %??Ñe??????????
if ~exist('Tamb', 'var'); Tamb=40; end %?????????????????????
if ~exist('Trad', 'var'); Trad=150; end %?????????????????????
if ~exist('Eshell', 'var'); Eshell=0.8; end %?????????????????
if ~exist('meta_rate', 'var'); meta_rate=120; end %?????§Ý?????????????
if ~exist('Lshell', 'var'); Lshell=0.0006; end %????????????????
if ~exist('kshell', 'var'); kshell=0.03; end %????????????????????
if ~exist('Dshell', 'var'); Dshell=100; end %?????????????????
if ~exist('Sshell', 'var'); Sshell=1000; end %???????????????????
if ~exist('Lair', 'var'); Lair=0.00; end %????????

% Print all input parameters in a single machine-parsable line
fprintf('INPUTS:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n', ...
    Tamb, Trad, meta_rate, Ret, Lair, Eshell, Lshell, Dshell, Sshell, kshell);


%???¨¹????
pcshell=Dshell*Sshell;%????????*¡À?????
icl=2.122/Ret;%????????????
met=meta_rate/58.2;

Lmsr=0.00005;%¡¤?????????????
Ltherm=0.00005;%??????????
Lx = Lshell+Lmsr+Ltherm+Lair; %????????(m)
dx = 0.00005; %???????¡è(m)
x = (0:dx:Lx);%????¡Á?¡À¨º??¡Á¨¦
nx = numel(x);  %??????????
n1=round(Lshell/dx);%??????????
n2=round(n1+Lmsr/dx);%¡¤???????????
n3=round(n2+Ltherm/dx);%????????????
n4=round(n3+Lair/dx)+1;%????????????
Kfab=(-log(0.01))/Lshell;%?¨¹??????
%¡¤???????????????????
kmsr=0.034;%????????
pcmsr=122*1160;%????*¡À?????
Emsr=0.9;%¡¤?????
%????????????????
ktherm=0.035;%????????
pctherm=111*1350;%????*¡À?????
Etherm=0.9;%¡¤?????
%?????????¡§300k??
pcair=1169*5298;%????*¡À?????
kair=0.0263;%????????
g=9.81;%??????????
BB=1/300;%?????¨°??????
aa=22.5*10^(-6);%??????????
vv=15.89*10^(-6);%????????
Kair=5;%?????¨¹??????
%?¡è¡¤?????
Eskin=0.9;%?¡è¡¤?¡¤?????
k1=0.628;%¡À¨ª?¡è????????
pc1=4.40*10^6;%¡À¨ª?¡è????*¡À?????
k2=0.5902;%???¡è????????
pc2=4.186*10^6;%???¡è????*¡À?????
k3=0.2930;%?¡è??¡Á¨¦??????????
pc3=2.60*10^6;%?¡è??¡Á¨¦??????*¡À?????
%time division?¡À????????
Lte =600; %¡À????¡À??(s)
Ltc=0;%?????¡À??
Lt =Lte+Ltc; %¡Á??¡À??(s)
dt =0.05; %?¡À?????¡è(s)
t =(0:dt:Lt);%?¡À??¡Á?¡À¨º??¡Á¨¦
nt = numel(t);%?¡À????????
%view factor????????
Ffab_amb=0.4475;%????-?¡¤??????????
Ffab_skin=0.948;%????-?¡è¡¤?????????
Frad_fab=0.3837;%¡¤???-????????????
%??¡¤???????
o=5.67*10^(-8);%????¡¤?-?¡§??¡Á??¨¹????
Erad=0.98;%¡¤?????¡¤?????
Eg=0.02;
P=8500;%???????¡§??
Asens=pi*(0.0254/2)^2;%?????¡Â????
Afab=0.1^2;%????????
Arad=0.12^2;%¡¤???????
AA1=Afab/Arad;%????¡À?1
AA2=Asens/Afab;%????¡À?2
%------------------------------------------------------------------------------------
%human model parameters
% ?¡§?????????¡Â??¡À¨ª?????????????¨´???¨²???¨²???????¡Â??¡¤?????
% ?¨¨?¡§????????????????????????/???????????¨²?¨ª??????
%?????????¨®???¡§
%??????????¡¤?¡¤¡§???¡§?????????¨®???¨®????????¡¤???
% Surface area of human segments, m^2,total area is 1.87
ADu=[0.0466 0.0466 0.0466 0.0466 0.0934 0.0934 0.0934 0.0934 0.0335 0.0335 0.0335 0.0335 0.0335 0.0335 0.0335 0.0335 ...
0.0295 0.0295 0.0295 0.0295	0.0295 0.0295 0.0295 0.0295 0.0500 0.0500 0.0500 0.0500 0.0500 0.0500 0.0500 0.0500 ... 	
0.1750 0.1750 0.1750 0.1750 0.1920 0.1920 0.1920 0.1920 0.0934 0.0934 0.0934 0.0934 0.1610 0.1610 0.1610 0.1610 ...
0.0638 0.0638 0.0638 0.0638 0.0638 0.0638 0.0638 0.0638 0.2090 0.2090 0.2090 0.2090 0.2090 0.2090 0.2090 0.2090 ...
0.1120 0.1120 0.1120 0.1120	0.1120 0.1120 0.1120 0.1120	0.0560 0.0560 0.0560 0.0560 0.0560 0.0560 0.0560 0.0560];  
% Heat capacity of each node, Wh/K; 1 W.h = 3600 J; 1 W.s = J; 
C=[0.8581 	0.1286 	0.0859 	0.0939 1.7179 	0.2574 	0.1721 	0.1881 0.1706 	0.3620 	0.0696 	0.0526 0.1706 	0.3620 	0.0696 	0.0526 0.1504 	0.3190 	0.0614 	0.0464 ...
0.1504 	0.3190 	0.0614 	0.0464 0.0820 	0.0370 	0.0520 	0.0990 0.0820 	0.0370 	0.0520 	0.0990 2.9150 	5.6990 	1.4960 	0.4180 1.0060 	2.1560 	0.4140 	0.3020 ...
2.5416 	3.3779 	0.8879 	0.2560 2.4710 	5.0220 	1.3220 	0.3860 1.7377 	2.3095 	0.6071 	0.1750 1.7377 	2.3095 	0.6071 	0.1750 1.6650 	3.6040 	0.5600 	0.4230 ...
1.6650 	3.6040 	0.5600 	0.4230 0.7930 	1.7150 	0.2680 	0.2040 0.7930 	1.7150 	0.2680 	0.2040 0.1390 	0.0370 	0.0770 	0.1250 0.1390 	0.0370 	0.0770 	0.1250].*3600;%
C81=2.610*3600;
% Heat production, W
Qb=[5.6104 	0.0723 	0.0363 	0.0436 11.2326 	0.1447 	0.0727 	0.0874 0.0500 	0.1170 	0.0165 	0.0138 0.0500 	0.1170 	0.0165 	0.0138 0.0440 	0.1030 	0.0145 	0.0122 ...
0.0440 	0.1030 	0.0145 	0.0122 0.0450 	0.0220 	0.0230 	0.0500 0.0450 	0.0220 	0.0230 	0.0500 21.1820 	2.5370 	0.5680 	0.1790 0.3620 	0.8460 	1.2200 	0.1000 ...
3.4003 	1.7179 	0.3396 	0.1073 18.6990 	2.5370 	0.5010 	0.1580 2.3248 	1.1745 	0.2322 	0.0734 2.3248 	1.1745 	0.2322 	0.0734 0.3430 	0.8240 	0.1510 	0.1220 ...
0.3430 	0.8240 	0.1510 	0.1220 0.1020 	0.2200 	0.0350 	0.0230 0.1020 	0.2200 	0.0350 	0.0230 0.1220 	0.0350 	0.0560 	0.1000 0.1220 	0.0350 	0.0560 	0.1000];
% Distribution coefficient of muscle layer.  
Metf=[0	0.0000 	0	0 0	0.0000 	0	0 0	0.0074 	0	0 0	0.0074 	0	0 0	0.0066 	0	0 ...
0	0.0066 	0	0 0	0.0050 	0	0 0	0.0050 	0	0 0	0.0910 	0	0 0	0.0520 	0	0 ...
0	0.0545 	0	0 0	0.0800 	0	0 0	0.0373 	0	0 0	0.0373 	0	0 0	0.2010 	0	0 ...
0	0.2010 	0	0 0	0.0990 	0	0 0	0.0990 	0	0 0	0.0050 	0	0 0	0.0050 	0	0];
% Basal blood flow rate, l/h?
BFB=[14.8950 0.2880 	0.1125 	0.7414 30.1050 	0.5820 	0.2275 	1.4986 0.0851 	0.3562 	0.0452 	0.2392 0.0851 	0.3562 	0.0452 	0.2392 0.0749 	0.3138 	0.0398 	0.2108 ...
0.0749 	0.3138 	0.0398 	0.2108 0.0910 	0.0780 	0.0420 	0.9100 0.0910 	0.0780 	0.0420 	0.9100 77.8500 	7.6600 	1.3400 	1.8000 0.6400 	2.5600 	0.3200 	1.7200 ...
7.6835 	5.1871 	0.9124 	0.8786 76.3400 	7.6600 	1.3400 	1.3500 5.2533 	3.5465 	0.6238 	0.6007 5.2533 	3.5465 	0.6238 	0.6007 0.3640 	0.8550 	0.1500 	0.3800 ... 
0.364	0.855	0.15	0.38 0.071	0.07	0.019	0.11 0.071	0.07	0.019	0.11 0.049	0.01	0.019	0.45 0.049	0.01	0.019	0.45]./1000/3600;
% Conduction between nodes in the same segment.
Cd=[1.601 13.224 16.008 1.601 13.224 16.008 0.244 2.227 7.888 0.244 2.227 7.888 0.244 2.227 7.888 ...
    0.244 2.227 7.888 2.181 6.484 5.858 2.181 6.484 5.858 0.616 2.100 9.164 0.441 2.964 7.308 ...
    0.379 1.276 5.104 0.594 2.018 8.700 0.379 1.276 5.104 0.379 1.276 5.104 2.401 4.536 30.160 ...
    2.401 4.536 30.160 1.891 2.656 7.540 1.891 2.656 7.540 8.120 10.266 8.178 8.120 10.266 8.178];
% Set point temperature     
Tset=[36.90 	36.10 	35.80 	35.60 36.90 	36.10 	35.80 	35.60 35.50 	34.80 	34.70 	34.60 35.50 	34.80 	34.70 	34.60 35.50 	34.80 	34.70 	34.60 35.50 	34.80 	34.70 	34.60 ...
35.40 	35.30 	35.30 	35.20 35.40 	35.30 	35.30 	35.20 36.50 	36.20 	34.50 	33.60 35.80 	34.60 	33.80 	33.40 36.30 	35.60 	34.50 	33.40 36.50 	35.80 	34.40 	33.20 ...
36.30 	35.60 	34.50 	33.40 36.30 	35.60 	34.50 	33.40 35.80 	35.20 	34.40 	33.80 35.80 	35.20 	34.40 	33.80 35.60 	34.40 	33.90 	33.40 35.60 	34.40 	33.90 	33.40 ...
35.10 	34.90 	34.40 	33.90 35.10 	34.90 	34.40 	33.90 36.70];
% Weighting coefficient for integration for sensor signals  
SKINR=[0	0	0	0.0233 0	0	0	0.0467 0	0	0	0.0064 0	0	0	0.0064 0	0	0	0.0056 ...
0	0	0	0.0056 0	0	0	0.0920 0	0	0	0.0920 0	0	0	0.1490 0	0	0	0.0460 ...
0	0	0	0.0895 0	0	0	0.1320 0	0	0	0.0612 0	0	0	0.0612 0	0	0	0.0500 ...
0	0	0	0.0500 0	0	0	0.0250 0	0	0	0.0250 0	0	0	0.0170 0	0	0	0.0170]; 
% Coefficient of skin layer for sweating   
SKINS=[0	0	0	0.0270 0	0	0	0.0540 0	0	0	0.0138 0	0	0	0.0138 0	0	0	0.0122 ...
0	0	0	0.0122 0	0	0	0.0160 0	0	0	0.0160 0	0	0	0.1460 0	0	0	0.1020 ...
0	0	0	0.0870 0	0	0	0.1290 0	0	0	0.0595 0	0	0	0.0595 0	0	0	0.0730 ...
0	0	0	0.0730 0	0	0	0.0360 0	0	0	0.0360 0	0	0	0.0180 0	0	0	0.0180];
% Coefficient of skin layer for DL?vasodilatation?
SKINV=[0	0	0	0.0666 0	0	0	0.1334 0	0	0	0.0085 0	0	0	0.0085 0	0	0	0.0075 ...
0	0	0	0.0075 0	0	0	0.0610 0	0	0	0.0610 0	0	0	0.0980 0	0	0	0.0620 ...
0	0	0	0.0583 0	0	0	0.0860 0	0	0	0.0399 0	0	0	0.0399 0	0	0	0.0920 ...
0	0	0	0.0920 0	0	0	0.0230 0	0	0	0.0230 0	0	0	0.0500 0	0	0	0.0500];
% Coefficient of skin layer for ST ?vasoconstriction?
SKINC=[0	0	0	0.0073 0	0	0	0.0147 0	0	0	0.0117 0	0	0	0.0117 0	0	0	0.0103 ...
0	0	0	0.0103 0	0	0	0.1520 0	0	0	0.1520 0	0	0	0.0650 0	0	0	0.0440 ...
0	0	0	0.0275 0	0	0	0.0650 0	0	0	0.0188 0	0	0	0.0188 0	0	0	0.0220 ...
0	0	0	0.0220 0	0	0	0.0220 0	0	0	0.0220 0	0	0	0.1520 0	0	0	0.1520];
% Coefficient of skin layer for shivering
Chit=[0	0.0067	0	0 0	0.0133	0	0 0	0.0138	0	0 0	0.0138	0	0 0	0.0122	0	0 ...
0	0.0122	0	0 0	0	0	0 0	0	0	0 0	0.258	0	0 0	0.008	0	0 ...
0	0.1542	0	0 0	0.227	0	0 0	0.1054	0	0 0	0.1054	0	0 0	0.023	0	0 ...
0	0.023	0	0 0	0.012	0	0 0	0.012	0	0 0	0	0	0 0	0	0	0]; 

Cch=0; Sch=0; Pch=24.4;% Coefficients
Cdl=117/1000/3600; Sdl=7.5/1000/3600; Pdl=0;% Coefficients
Cst=11.5/1000; Sst=11.5/1000; Pst=0;% Coefficients
Csw=371.2; Ssw=33.6; Psw=0;% Coefficients

wl=2260;%J/g
br=1.067*3600*1000;% Volumetric specific heat of blood, Wh/loC 
a=1.000; % Constant.

Stefan=5.67*10^-8;% Constant
embody=0.99;% emissivity
emenv=1;% emissivity
viewseat=[0.95 0.95 0.95 0.95 0.90 0.90 0.90 0.90 0.775 0.775 0.775 0.775 0.775 0.775 0.775 0.775 0.775 0.775 0.775 0.775 ...
      0.775 0.775 0.775 0.775 0.80 0.80 0.80 0.80 0.80 0.80 0.80 0.80 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 ...
      0.875 0.875 0.875 0.875 0.90 0.90 0.90 0.90 0.875 0.875 0.875 0.875 0.875 0.875 0.875 0.875 0.85 0.85 0.85 0.85 ... 
      0.85 0.85 0.85 0.85 0.85 0.85 0.85 0.85 0.85 0.85 0.85 0.85 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90];% 
viewstand=[0.95 0.95 0.95 0.95 0.90 0.90 0.90 0.90 0.875 0.875 0.875 0.875 0.875 0.875 0.875 0.875 0.875 0.875 0.875 0.875 ...
      0.875 0.875 0.875 0.875 0.80 0.80 0.80 0.80 0.80 0.80 0.80 0.80 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 ...
      0.925 0.925 0.925 0.925 0.90 0.90 0.90 0.90 0.925 0.925 0.925 0.925 0.925 0.925 0.925 0.925 0.90 0.90 0.90 0.90 ... 
      0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90 0.90];
% Thermal insulation(only fabric), clo,clothing1-0.62/clothing2-0.83
Icl=1.83*[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ...
     1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ...
     1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]; %??¡Á¨¨
% Matrix I 
I=[0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 ...
   0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1]; 
Pc=I; % All the body segmetns are covered by clothing
Punc=I-Pc; % Uncltohed segments (0)
% Part of the segments are clothed
Pc2=[0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	1	0 ...	
       0	0	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0 ...	
       0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 ...
       0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 ...
       0	0	0	0	0	0	0	0	0	0	0	0]; 
Punc2=I-Pc2; % Part of the segments are unclothed   
Area=1.87;

 % 20150928 Validation simulation
  %ta=20; RH=0.5; v=0.33; tr=20; met=1; icl=0.40; % Inititavie value of the simulation
  %ta=30.0; RH=0.87; v=0.33; tr=30.0; met=165/58.2; icl=0.40; % Inititavie value of the simulation
  %ta=20; RH=0.47; v=0.33; tr=20; met=58.2/58.2; icl=0.47; % met=110/58.2;
  %ta=30; RH=0.86; v=0.33; tr=30; met=177/58.2; icl=0.47; % At ambient temperature of 30 degree; 20151014
  %ta=40; RH=0.45; v=0.33; tr=40; met=300/58.2; icl=0.30; % Clothing 3, High Version; At ambient temperature of 40 degree; 20151017
  %ta=40;RH=0.70; v=0.30; tr=40; met=400/58.2; icl=0.5305; % Initial value for OS+MB+TL70
  %ta=Tamb;RH=0.70; v=0.30; tr=Tamb; icl=0.3;
  ta=Tamb;      % ?¡¤???????????¡§???¡ã?¡§????Tamb?????¡¤????????
  RH=0.70;      % ?¨¤?????? = 70%
  v=0.30;       % ?????¡Â?? = 0.30 m/s
  tr=Tamb;      % ???¨´¡¤????????¡§???¡¤???????¨¤????
% Initial value for OS+MB+TL150
%?????¨´?????????¡ì?¡¤????????????????????

%difine F
%Fshell=kshell/pcshell*(dt/(dx^2))/2;
Ftherm=ktherm/pctherm*(dt/(dx^2))/2;
Fmsr=kmsr/pcmsr*(dt/(dx^2))/2;
Fair=kair/pcair*(dt/(dx^2))/2;
%difine matrix
M = zeros(nx,nx);
N = zeros(nx,nx);
WW = zeros(nx,1);
V = zeros(nx,1);
%tri-diagonal
for i = n1+2:1:n2
 M(i,i-1) = (-Fmsr);
 M(i,i) = (1+(2*Fmsr));
 M(i,i+1) = (-Fmsr);
 N(i,i-1) = (Fmsr);
 N(i,i) = (1-(2*Fmsr));
 N(i,i+1) = (Fmsr);
end
M(n2+1,n2) =-kmsr;
M(n2+1,n2+1) =ktherm+kmsr;
M(n2+1,n2+2) =-ktherm;
N(n2+1,n2) =kmsr;
N(n2+1,n2+1) =-(ktherm+kmsr);
N(n2+1,n2+2) =ktherm;
%moisture barrier
for i = n2+2:1:n3
 M(i,i-1) = (-Ftherm);
 M(i,i) = (1+(2*Ftherm));
 M(i,i+1) = (-Ftherm);
 N(i,i-1) = (Ftherm);
 N(i,i) = (1-(2*Ftherm));
 N(i,i+1) = (Ftherm);
end
%Thermal liner
M(n3+1,n3) =ktherm;
M(n3+1,n3+1) =-(ktherm+kair);
M(n3+1,n3+2) =kair;
N(n3+1,n3) =0;
N(n3+1,n3+1) =0;
N(n3+1,n3+2) =0;
%air gap
for i=n3+2:1:n4-1
 M(i,i-1) = (-Fair);
 M(i,i) = (1+(2*Fair));
 M(i,i+1) = (-Fair);
 N(i,i-1) = (Fair);
 N(i,i) = (1-(2*Fair));
 N(i,i+1) = (Fair);
 end
%skin surface
M(n4,n4-1)=0;
M(n4,n4)=1;
N(n4,n4-1)=0;
N(n4,n4)=1;

for i =1:n4
    T(i,1)=Tamb;
end
%initial conditions of human model
TT(:,1)=[36.7008404639312	36.0661130154137	35.9805360962327	35.9070476599459	36.7208769404366	35.9015189769809	35.7763810594272	35.6640581956889	35.6678572642855	35.4747804526169	35.1642874343830	35.0710486703904	35.6678572642855	35.4747804526169	35.1642874343830	35.0710486703904	35.6428096674126	35.4657278696321	35.1868487966135	35.1032823333691	35.6428096674126	35.4657278696321	35.1868487966135	35.1032823333691	35.4113476936804	35.3624774767159	35.2948183405239	35.2114962477242	35.4113476936804	35.3624774767159	35.2948183405239	35.2114962477242	36.5798507638812	36.4562296020544	35.5798934953332	35.2774395426804	36.1146724938472	36.0506845068670	35.4589426939015	35.0276521092382	36.6786040294281	36.4057672393197	35.5892970202041	35.2790932203727	36.6541063086465	36.4002489093940	35.4611863402092	35.1202953907455	36.6700399924051	36.3679401030300	35.6200614907507	35.3592276122424	36.6700399924051	36.3679401030300	35.6200614907507	35.3592276122424	35.9282634858916	36.0205705950993	34.8258094952828	34.6426682932985	35.9282634858916	36.0205705950993	34.8258094952828	34.6426682932985	35.4558199464831	35.6104392748313	34.5084926578869	34.1339257507453	35.4558199464831	35.6104392748313	34.5084926578869	34.1339257507453	34.6591465120094	34.6823339076514	34.5754853253654	34.5178672679791	34.6591465120094	34.6823339076514	34.5754853253654	34.5178672679791	36.4452060751723]'; 

%?¡Â???¡¤-?¡À??????????
for n = 2:nt
    %??¡À????¡Á??????
  if n>Lte/dt+2;
    tr=30;%?????¡Á??????
    ta=30;
  end
  % ?¨¹???¡è¡¤?¡À¨ª??????
  %T(n4,n-1)=TR;??????????????¡À???
  T(n4,n-1)=TT(8,n-1);
  T(n4,1)=Tamb;
  %WW(n4,1)=TT(8,n-1);
 %Change in the thermal properties of out shell over temperature
 %kshell=0.8*(0.026+0.000068*(T(round(Lshell/dx/2),n-1)-27))+0.2*(0.13+0.0018*(T(round(Lshell/dx/2),n-1)-27));
  %pcshell=292*(1300+1.8*(T(round(Lshell/dx/2),n-1)-27));
  kshell=0.047;
  pcshell=342*1570;
  Fshell=kshell/pcshell*(dt/(dx^2))/2;
  Ra=g*BB*(0.1^3)*(T(1,n-1)-27)/aa/vv;
  Nu=0.68+0.67*(Ra.^0.25)/(1+(0.429/0.7)^(9/16))^(4/9);
  ho=Nu*kair/0.1;
 %outer boundary
  M(1,1) =1+2*Fshell;
  M(1,2) =-2*Fshell;
  N(1,1) =1-2*Fshell;
  N(1,2) =2*Fshell;
 %outer shell
for i = 2:1:n1
  M(i,i-1) = (-Fshell);
  M(i,i) = (1+(2*Fshell));
  M(i,i+1) = (-Fshell);
  N(i,i-1) = (Fshell);
  N(i,i) = (1-(2*Fshell));
  N(i,i+1) = (Fshell);
end
 %inner boundary condition
  M(n1+1,n1) =-kshell;
  M(n1+1,n1+1) =kshell+kmsr;
  M(n1+1,n1+2) =-kmsr;
  N(n1+1,n1) =kshell;
  N(n1+1,n1+1) =-(kshell+kmsr);
  N(n1+1,n1+2) =kmsr;
 %heat exposure phase¡¤??????¡§??????
    qrad_shell=1.44*o*(Erad*(Trad+273.15)^4-Eshell*(T(1,n-1)+273.15)^4)*Frad_fab;
    qrad_amb=Eshell*o*Ffab_amb*((T(1,n-1)+273.15)^4-(Tamb+273.15)^4)*(1-Erad);
    qconv(n-1)=ho*(T(1,n-1)-Tamb);
    qrad1(n-1)=(qrad_shell);
    qrad11(n-1)=(-qrad_amb)-qconv(n-1);
    qrad(n-1)=qrad1(n-1)+qrad11(n-1);
    WW(1,1)= dt/(pcshell)*(Kfab)*qrad1(n-1)+4*Fshell*dx/kshell*qrad11(n-1);
    %radiant heat transfer
    for i =2:1:n1
    WW(i,1)=dt/(pcshell)*(Kfab)*qrad1(n-1)*exp(-Kfab*(i-1)*dx);
    end
    %boundary condition between OS and MB
    WW(n1+1,1)= 2*dx*qrad1(n-1)*exp(-Kfab*(n1)*dx); 

    %thermal radiation in air gap
    qrad2=o*((T(n3,n-1)+273.15)^4-(T(n4,n-1)+273.15)^4)/((1/Etherm-1+1/Ffab_skin)+1/Eskin-1);
    WW(n3+1,1)=dx*qrad2;
    %??????????????
    for i =n3+2:1:n4-1
    WW(i,1)=dt/(pcair)*Kair*qrad2*exp(-Kair*dx*(i-n3-1));
    end
Nh(:,n-1)=N*T(1:n4,(n-1))+WW(:,1);
mh(1,1)=M(1,1);
nh(1,n-1)=Nh(1,n-1);
for i=2:nx
mh(i,i)=M(i,i)-M(i,i-1)*M(i-1,i)/mh(i-1,i-1);
nh(i,n-1)=Nh(i,n-1)-M(i,i-1)/mh(i-1,i-1)*nh(i-1,n-1);
end
T(nx,n)=nh(nx,n-1)/mh(nx,nx);
for i=nx-1:-1:1
T(i,n)=(nh(i,n-1)-M(i,i+1)*T(i+1,n))/mh(i,i);
end     
%T(:,n)=M\(N*T(:,(n-1))+W(:,1)-V(:,1));
%------------------------------------------------------------------------------------
% skin heat flux
qskin(n-1)=qrad2*exp(-Kair*Lair)-kair*(T(n4,n-1)-T(n4-1,n-1))/dx;
%qt=load('C:\Users\yunsu\Desktop\Yun\Model 2017(Work with Yun)\test-data/Rad-os+mb-4.txt');      
%Skin heat flux for each node    
for i=1:1:80
     Qt(i,n-1)=qskin(n-1)*ADu(i);
     %Qt(i,n)=1000*ADu(i);
end
%calculation of human model
%Node 1
for i=1:80 
   if TT(i,n-1)>Tset(i)
    Qadd(i)=Qb(i)*(2^(0.1*(TT(i,n-1)-Tset(i)))-1);
    else if TT(i,n-1)<=Tset(i)
    Qadd(i)=0;
        end
    end
end
for i=1:80 
   if TT(i,n-1)>Tset(i)
     BFBadd(i)=BFB(i)*(2^(0.1*(TT(i,n-1)-Tset(i)))-1);
    else if TT(i,n-1)<=Tset(i)
     BFBadd(i)=0;
        end
    end
end
%Node 2
for i=1:80 
    Err(i)=TT(i,n-1)-Tset(i);
    if Err(i)>=0;
        Wrm(i)=Err(i);
        Cld(i)=0;
    else if Err(i)<0;
        Cld(i)=-Err(i);
        Wrm(i)=0;
    end
    end
end
Wrms=SKINR*Wrm'; % Warm signals
Clds=SKINR*Cld'; % Colde signals

for i=1:80
Ch(i)=(-Cch*Err(1)-Sch*(Wrms-Clds)+Pch*Cld(1)*Clds)*Chit(i);
if Ch(i)<0
Ch(i)=0;
end
end

for i=1:80
    W(i)=58.2*(met-0.778)*Area*Metf(i); 
end 
%Node 4
hc=[0.1 0.1 0.1 (3*(abs(TT(4,n-1)-ta))^0.5+113*v-10.8)^0.5 0.1 0.1 0.1 (3*(abs(TT(8,n-1)-ta))^0.5+113*v-10.8)^0.5 0.1 0.1 0.1 (8.3*(abs(TT(12,n-1)-ta))^0.5+216*v-10.8)^0.5 0.1 0.1 0.1 (8.3*(abs(TT(16,n-1)-ta))^0.5+216*v-10.8)^0.5 ...
    0.1 0.1 0.1 (8.3*(abs(TT(20,n-1)-ta))^0.5+216*v-10.8)^0.5 0.1 0.1 0.1 (8.3*(abs(TT(24,n-1)-ta))^0.5+216*v-10.8)^0.5 0.1 0.1 0.1 (8.3*(abs(TT(28,n-1)-ta))^0.5+216*v-10.8)^0.5 0.1 0.1 0.1 (8.3*(abs(TT(32,n-1)-ta))^0.5+216*v-10.8)^0.5 ...
    0.1 0.1 0.1 (0.5*(abs(TT(36,n-1)-ta))^0.5+180*v-7.4)^0.5 0.1 0.1 0.1 (5.9*(abs(TT(40,n-1)-ta))^0.5+216*v-10.8)^0.5 0.1 0.1 0.1 (1.2*(abs(TT(44,n-1)-ta))^0.5+180*v-9)^0.5 0.1 0.1 0.1 (5.9*(abs(TT(48,n-1)-ta))^0.5+216*v-10.8)^0.5 ...
    0.1 0.1 0.1 (5.9*(abs(TT(52,n-1)-ta))^0.5+216*v-10.8)^0.5 0.1 0.1 0.1 (5.9*(abs(TT(56,n-1)-ta))^0.5+216*v-10.8)^0.5 0.1 0.1 0.1 (5.3*(abs(TT(60,n-1)-ta))^0.5+220*v-11)^0.5 0.1 0.1 0.1 (5.3*(abs(TT(64,n-1)-ta))^0.5+220*v-11)^0.5 ...
    0.1 0.1 0.1 (5.3*(abs(TT(68,n-1)-ta))^0.5+220*v-11)^0.5 0.1 0.1 0.1 (5.3*(abs(TT(72,n-1)-ta))^0.5+220*v-11)^0.5 0.1 0.1 0.1 (6.8*(abs(TT(76,n-1)-ta))^0.5+210*v-10.5)^0.5 0.1 0.1 0.1 (6.8*(abs(TT(80,n-1)-ta))^0.5+210*v-10.5)^0.5];% From Fiala's work

he=16.5*hc; % Evaporative heat transfer coefficient
for i=1:80 
   Esw(i)=(Csw*Err(1)+Ssw*(Wrms-Clds)+Psw*Wrm(1)*Wrms)*SKINS(i)*2^(Err(i)/10)*0.2; % Heat loss via sweating
end 
%%%%%%%%%%%%%%?????????¡¤??????????????????????????0.05
for i=1:80
   if Esw(i)<=0;
      Esw1(i)=0;
   else if Esw(i)>0;
      Esw1(i)=Esw(i);
   end
   end
end

for i=1:80
Msw(i,n-1)=Esw1(i)/wl; % 1 g/(m2*s)=3600*ml/(m2*h),Wan's model
   if Msw(i)<=0;
    isk=0.33;%evaporative resistance of the skin, m2kpa/W
    iask=0.0129;% evaporative resistance of the adjacent air layer
    hfg=2.26*10^3; %water latent heat of vaporization, j/kg
    Psatsk(i)=133.3*10^(5.10765-1750.29/(235+TT(i,n-1)));%
    Pa=RH*133.3*10^(5.10765-1750.29/(235+ta));%
    Psk(i)=(Psatsk(i)*iask+Pa*isk+Msw(i,n-1)*hfg*isk*iask)/(isk+iask);% Vapor pressure at skin 
    end
   if Msw(i,n-1)>0&Msw(i,n-1)<=5/6; 
    Psk(i)=133.3*10^(5.10765-1750.29/(235+TT(i,n-1))); % Saturation vapor pressure
   end
   if Msw(i,n-1)>5/6/Area; 
    Msw(i,n-1)=5/6/Area; 
    Psk(i)=133.3*10^(5.10765-1750.29/(235+TT(i,n-1))); % Saturation vapor pressure
   end
end 
%------------------------------------------------------------------------------------
%Unclothed segment
for i=1:80
Emaxunc(i)=he(i)*(Psk(i)-Pa)*ADu(i);% Latent heat loss for unclothed segments
Eunc(i)=0.06*(1-Esw1(i)/Emaxunc(i))*Emaxunc(i)+Esw1(i);% Total heat loss for unclothed segments
end 
%------------------------------------------------------------------------------------

%Clothed segment
for i=1:80   
fcl(i)=1+0.31*Icl(i);% Area factor
hec(i)=(16.5*icl)/(0.155*Icl(i)+icl/(hc(i)*fcl(i)));% Evaprative heat transfer coefficient, W/(m2Kpa)
Emaxc(i)=hec(i)*(Psk(i)-Pa)*ADu(i);% 
Ec(i)=0.06*(1-Esw1(i)/Emaxc(i))*Emaxc(i)+Esw1(i);% 
E(i,n-1)=Ec(i)*Pc(i)+Eunc(i)*Punc(i);% Latent heat loss of clothed and unclothed segments
end
%--------------------------------------------------------------------------------------

DL(n-1)=Cdl*Err(1)+Sdl*(Wrms-Clds)+Pdl*Wrm(1)*Wrms;
if DL(n-1)<0
   DL(n-1)=0;
end
ST=-Cst*Err(1)-Sst*(Wrms-Clds)+Pst*Cld(1)*Clds;
if ST<0
    ST=0;
end
% 33chest respiration
Q=Qb+W+Ch;
RES=(0.0014*(34-ta)+0.0173*(5.876-Pa))*sum(Q);
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------
%Mean skin tepmeratures=TT(:,20)*0.3+TT(:,36)*0.3+TT(:,64)*0.2+TT(:,68)*0.2;
%Core layer
for i=1:4:77
B(i,n-1)=a*br*(BFB(i)+BFBadd(i))*(TT(i,n-1)-TT(81,n-1));
dT(i,n-1)=(Qb(i)+Qadd(i)-B(i,n-1)-Cd(i-(i-1)/4)*(TT(i,n-1)-TT(i+1,n-1)))/C(i);% 
end
dT(33,n-1)=(Qb(33)+Qadd(33)-B(33,n-1)-Cd(25)*(TT(33,n-1)-TT(34,n-1))-RES)/C(33);% 
%muscle layer
for i=2:4:78
B(i,n-1)=a*br*(BFB(i)+BFBadd(i)+(W(i)+Ch(i))/1.16/1000/3600)*(TT(i,n-1)-TT(81,n-1));% 
dT(i,n-1)=(Qb(i)+Qadd(i)+W(i)+Ch(i)-B(i,n-1)+Cd(i-(i+2)/4)*(TT(i-1,n-1)-TT(i,n-1))-Cd(i-(i-2)/4)*(TT(i,n-1)-TT(i+1,n-1)))/C(i);% 
end
%fat layer
for i=3:4:79
B(i,n-1)=a*br*(BFB(i)+BFBadd(i))*(TT(i,n-1)-TT(81,n-1));
dT(i,n-1)=(Qb(i)+Qadd(i)-B(i,n-1)+Cd(i-(i+1)/4)*(TT(i-1,n-1)-TT(i,n-1))-Cd(i-(i-3)/4)*(TT(i,n-1)-TT(i+1,n-1)))/C(i);% 
end
%skin layer
for i=4:4:80
BF(i,n-1)=(BFB(i)+BFBadd(i)+SKINV(i)*DL(n-1))*(2^(Err(i)/10))/(1+SKINC(i)*ST);
BF(i,n-1)=(BFB(i)+BFBadd(i));
B(i,n-1)=a*br*BF(i,n-1)*(TT(i,n-1)-TT(81,n-1));
dT(i,n-1)=(Qb(i)+Qadd(i)-B(i,n-1)+Cd(i-i/4)*(TT(i-1,n-1)-TT(i,n-1))+Qt(i,n-1)-E(i,n-1))/C(i); % Change Qt(4) to Qt
%dT(i)=(Qb(i)+Qadd(i)-B(i)+Cd(i-i/4)*(TT(i-1,j)-TT(i,j))+1000-E(i))/C(i); % Change Qt(4) to Qt
end
% 81
Blood=sum(B(:,n-1));
dT(81,n-1)=Blood/C81;
%difference method
TT(:,n)=TT(:,n-1)+dt*dT(:,n-1);
end
Temperature=TT';
Taverage=0.07*Temperature(:,4)+0.35*Temperature(:,44)+0.14*Temperature(:,12)+0.05*Temperature(:,28)+0.19*Temperature(:,60)+0.13*Temperature(:,68)+0.07*Temperature(:,80);
qskin=qskin'/1000;
qskin1=qskin(1:(nt-1)/Lt:nt-1,:);
%?????????¡è?¡À??
Tcore=Temperature(:,33);
target = 38.5;
idxAll = find(Tcore> target);      % ?¨´???¨®?? 38.5 ??????
[~,j]  = min(abs(Tcore(idxAll) - target));  % ¡Á??¨¹???????? idxAll ?????¨°??
bestIdx = idxAll(j);                            % ???????????¨®??????¡À¨º
tstress = (bestIdx)*dt;  %?????¡è¡¤??¨²?¡À??
Tcore=Temperature(1:(nt-1)/Lt:nt,33); % 1s time interval????????????
Taverage=Taverage(1:(nt-1)/Lt:nt,1);  %???????¨´?¡è¡¤?????

%____________________________________________________________________________________________________
%%%?????????¡è¡¤????????¡è¡¤??????¡À??
L1=7.5*10^(-5);
L2=1.125*10^(-3);
L3=3.885*10^(-3);
Lskin=L1+L2+L3;
Lx = Lshell+Lmsr+Ltherm+Lair+Lskin; %Thickness of system (m)
x = (0:dx:Lx);
nx = numel(x);  
t =(0:dt:Lt);
nt = numel(t);
n1=round(Lshell/dx);
n2=round(n1+Lmsr/dx);
n3=round(n2+Ltherm/dx);
n4=round(n3+Lair/dx);
n5=round(n4+L1/dx);
n6=round(n5+L2/dx);
n7=round(n6+L3/dx)-1;
%????????????F¡À???
%Fshell=kshell/pcshell*(dt/(dx^2))/2;
Ftherm=ktherm/pctherm*(dt/(dx^2))/2;
Fmsr=kmsr/pcmsr*(dt/(dx^2))/2;
Fair=kair/pcair*(dt/(dx^2))/2;
F1=k1*dt/(2*pc1*(dx^2));
F2=k2*dt/(2*pc2*(dx^2));
F3=k3*dt/(2*pc3*(dx^2));
Tb=37+273.15;
%?¡§???????????¨®M
M = zeros(nx,nx);
N = zeros(nx,nx);
W = zeros(nx,1);
V = zeros(nx,1);
%¡¤???????????????????¡¤?
for i = n1+2:1:n2
 M(i,i-1) = (-Fmsr);
 M(i,i) = (1+(2*Fmsr));
 M(i,i+1) = (-Fmsr);
 N(i,i-1) = (Fmsr);
 N(i,i) = (1-(2*Fmsr));
 N(i,i+1) = (Fmsr);
end
M(n2+1,n2) =-kmsr;
M(n2+1,n2+1) =ktherm+kmsr;
M(n2+1,n2+2) =-ktherm;
N(n2+1,n2) =kmsr;
N(n2+1,n2+1) =-(ktherm+kmsr);
N(n2+1,n2+2) =ktherm;
%????????????????¡¤?
for i = n2+2:1:n3
 M(i,i-1) = (-Ftherm);
 M(i,i) = (1+(2*Ftherm));
 M(i,i+1) = (-Ftherm);
 N(i,i-1) = (Ftherm);
 N(i,i) = (1-(2*Ftherm));
 N(i,i+1) = (Ftherm);
end
%??????????????¡À???????
M(n3+1,n3) =ktherm;
M(n3+1,n3+1) =-(ktherm+kair);
M(n3+1,n3+2) =kair;
N(n3+1,n3) =0;
N(n3+1,n3+1) =0;
N(n3+1,n3+2) =0;
%????????????¡¤?
for i=n3+2:1:n4
 M(i,i-1) = (-Fair);
 M(i,i) = (1+(2*Fair));
 M(i,i+1) = (-Fair);
 N(i,i-1) = (Fair);
 N(i,i) = (1-(2*Fair));
 N(i,i+1) = (Fair);
 end
%?¡è¡¤?¡À¨ª??¡À¨ª????????¡¤?
M(n4+1,n4) =-kair;
M(n4+1,n4+1) =kair+k1;
M(n4+1,n4+2) =-k1;
N(n4+1,n4) =0;
N(n4+1,n4+1) =0;
N(n4+1,n4+2) =0;
%?¡è¡¤?¡À¨ª????????¡¤?
for i=n4+2:1:n5
 M(i,i-1) = (-F1);
 M(i,i) = (1+(2*F1));
 M(i,i+1) = (-F1);
 N(i,i-1) = (F1);
 N(i,i) = (1-(2*F1));
 N(i,i+1) = (F1);
end
 M(n5+1,n5) = -k1;
 M(n5+1,n5+1) = k1+k2;
 M(n5+1,n5+2) = -k2;
 N(n5+1,n5) = k1;
 N(n5+1,n5+1) = -(k1+k2);
 N(n5+1,n5+2) =k2;
for i =n5+2:1:n6 %?¡è¡¤????¡è??????
 M(i,i-1) = (-F2);
 M(i,i) = 1+(2*F2);
 M(i,i+1) = (-F2);
 N(i,i-1) = (F2);
 N(i,i) = 1-(2*F2);
 N(i,i+1) = (F2);
end
 M(n6+1,n6) = -k2;
 M(n6+1,n6+1) = k2+k3;
 M(n6+1,n6+2) = -k3;
 N(n6+1,n6) = k2;
 N(n6+1,n6+1) = -(k3+k2);
 N(n6+1,n6+2) = k3;
for i =n6+2:1:n7-1 %?¡è¡¤?¡Á¨¦??????
 M(i,i-1) = (-F3);
 M(i,i) = 1+(2*F3);
 M(i,i+1) = (-F3);
 N(i,i-1) = (F3);
 N(i,i) = 1-(2*F3);
 N(i,i+1) = (F3);
end
%?????¡Â????¡¤?
M(n7,n7-1)=0;
M(n7,n7)=1;
N(n7,n7-1)=0;
N(n7,n7)=1;
%?¡§??????????
Tamb=Tamb+273.15;%?¡¤??????
for i =1:n4
    T(i,1)=Tamb;
end
for i =n4+1:n7
    T(i,1)=305.65+(i-n4-1)*dx*(33.5-32.5)/Lskin;
end
%?????????????¨®
for n = 2:nt
 %?¡§????????¡À???????????
  %kshell=0.8*(0.026+0.000068*(T(round(Lshell/dx/2),n-1)-300))+0.2*(0.13+0.0018*(T(round(Lshell/dx/2),n-1)-300));
  %pcshell=292*(1300+1.8*(T(round(Lshell/dx/2),n-1)-300));
  Fshell=kshell/pcshell*(dt/(dx^2))/2;
  Ra=g*BB*(0.1^3)*(T(1,n-1)-300)/aa/vv;
  Nu=0.68+0.67*(Ra^0.25)/(1+(0.429/0.7)^(9/16))^(4/9);
  ho=Nu*kair/0.1;
 %???????¨¤??¡¤?
  M(1,1) =1+2*Fshell;
  M(1,2) =-2*Fshell;
  N(1,1) =1-2*Fshell;
  N(1,2) =2*Fshell;
 %??????????????¡¤?
for i = 2:1:n1
  M(i,i-1) = (-Fshell);
  M(i,i) = (1+(2*Fshell));
  M(i,i+1) = (-Fshell);
  N(i,i-1) = (Fshell);
  N(i,i) = (1-(2*Fshell));
  N(i,i+1) = (Fshell);
end
 %???????????¨¤??¡¤?
  M(n1+1,n1) =-kshell;
  M(n1+1,n1+1) =kshell+kmsr;
  M(n1+1,n1+2) =-kmsr;
  N(n1+1,n1) =kshell;
  N(n1+1,n1+1) =-(kshell+kmsr);
  N(n1+1,n1+2) =kmsr;
 %???????¨¤¡À???
    qrad_shell=1.44*o*(Erad*(Trad+273.15)^4-Eshell*T(1,n-1)^4)*Frad_fab;
    qrad_amb=Eshell*o*Ffab_amb*(T(1,n-1)^4-Tamb^4)*(1-Erad);
    qconv(n-1)=ho*(T(1,n-1)-Tamb);
    qrad1(n-1)=(qrad_shell);
    qrad11(n-1)=(-qrad_amb)-qconv(n-1);
    qrad(n-1)=qrad1(n-1)+qrad11(n-1);
    W(1,1)= dt/(pcshell)*(Kfab)*qrad1(n-1)+4*Fshell*dx/kshell*qrad11(n-1);
    %????????????????
    for i =2:1:n1
           W(i,1)=dt/(pcshell)*(Kfab)*qrad1(n-1)*exp(-Kfab*(i-1)*dx);
    end
    %??????????¡À???
    W(n1+1,1)= 2*dx*qrad1(n-1)*exp(-Kfab*(n1)*dx);  
    %????????????¡À???
    qrad2=o*(T(n3,n-1)^4-T(n4,n-1)^4)/((1/Etherm-1+1/Ffab_skin)+1/Eskin-1);
    W(n3+1,1)=dx*qrad2;
    %??????????????
    for i =n3+2:1:n4
    W(i,1)=dt/(pcair)*Kair*qrad2*exp(-Kair*dx*(i-n3-1));
    end
    %?????????¡è¡¤?¡À???
    W(n4+1,1)=dx*qrad2*exp(-Kair*Lair);
    %?¡è¡¤?¡Á¨¦????????
Nhs(:,n-1)=N*T(:,(n-1))+W(:,1);
mh(1,1)=M(1,1);
nh(1,n-1)=Nhs(1,n-1);
for i=2:nx
mh(i,i)=M(i,i)-M(i,i-1)*M(i-1,i)/mh(i-1,i-1);
nh(i,n-1)=Nhs(i,n-1)-M(i,i-1)/mh(i-1,i-1)*nh(i-1,n-1);
end
T(nx,n)=nh(nx,n-1)/mh(nx,nx);
for i=nx-1:-1:1
T(i,n)=(nh(i,n-1)-M(i,i+1)*T(i+1,n))/mh(i,i);
end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%?????????????¡À??
A1=T(n4+1,:);
Tskin=T(n4+1,:);
for i=1:1:nt
    if A1(i)<317.15
        R1(i)=0;
    else if A1(i)>=317.15&A1(i)<=323.15
        R1(i)=2.185*(10^124)*exp(-93534.9./A1(i));
    else if A1(i)>323.15
        R1(i)=1.823*(10^51)*exp(-39109.8./A1(i));
        end
        end
    end
end
S1(1)=0;
format short;
for N=1:1:(nt-1);
   D1=dt*(R1(N)+R1(N+1))/2;
S1(N+1)=S1(N)+D1;
end
U1=S1(nt); 
 %???????¨®?¡¤?¡Á?¡è??¡¤?
if U1>=0.53 %1st degree burn time
    D1=find(S1>0&S1<=0.53);
    E1=find(S1==max(S1(D1)));
    t1burn=t(E1);
else if U1<0.53
   T1burn=0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%?????????????¡À??
A=T(n5+1,:);
for i=1:1:nt
    if A(i)<317.15
        R(i)=0;
    else if A(i)>=317.15&A(i)<=323.15
        R(i)=2.185*(10^124)*exp(-93534.9./A(i));
    else if A(i)>323.15
        R(i)=1.823*(10^51)*exp(-39109.8./A(i));
        end
        end
    end
end
S(1)=0;
format short;
for N=1:1:(nt-1);
   D=dt*(R(N)+R(N+1))/2;
S(N+1)=S(N)+D;
end
U=S(nt); 
if U>=1 %??¡¤??¨²????????
    C=find(S>0&S<=1.5);
    B=S(C); %¡À?????????????¡¤?
    D=find(S>0&S<=1);
    E1=find(S==max(S(D)));
    t2burn=t(E1);
else if U<1
   t2burn=600;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%?????????????¡À??
AA=T(n6+1,:);%?¡è??¡Á¨¦????????
for i=1:1:nt
    if AA(i)<317.15
        r(i)=0;
    else if AA(i)>=317.15&AA(i)<=323.15
        r(i)=4.322*(10^64)*exp(-50000./AA(i));
    else if AA(i)>323.15
        r(i)=9.389*(10^104)*exp(-80000./AA(i));
        end
        end
    end
end
 %???????¨®?¡¤?¡Á?¡è????
 %????????
s(1)=0;
for n=1:1:(nt-1);
  d=dt*(r(n)+r(n+1))/2;
s(n+1)=s(n)+d;
end
u=s(nt);
if u>=1 %??¡¤??¨²????????
    c=find(s>0&s<=1.5);
    b=s(C); %¡À?????????????¡¤?
    d=find(s>0&s<=1);
    e=find(s==max(s(d)));
    t3burn=t(e);
else if  u<1
    t3burn=600;
    end
end
Tskin=(T(n5+1,1:(nt-1)/Lt:nt)- 273.15 * ones(1,(nt-1)*dt+1))'; % 1s time interval?????¡è¡¤?????

% -------------------------------------------------------------------------
% Machine-parsable export: 600 (Tcore) + 600 (Taverage) + 3 (summary)
try
    core600 = Tcore(:).';
    if numel(core600) < 600
        core600 = [core600, zeros(1, 600 - numel(core600))];
    else
        core600 = core600(1:600);
    end

    avg600 = Taverage(:).';
    if numel(avg600) < 600
        avg600 = [avg600, zeros(1, 600 - numel(avg600))];
    else
        avg600 = avg600(1:600);
    end

    % Order required: t2burn, t3burn, tstress, then Tcore(600), Taverage(600)
    header3 = [t2burn, t3burn, tstress];
    all_results = [header3(:); core600(:); avg600(:)];
    fprintf('RESULTS:%s\n', strjoin(string(all_results.'), ','));
catch ME
    warning('RESULTS export failed: %s', ME.message);
end

function [ s, ss, sl, rl ] = bdb( sb, M, Ts, Te, g, h, nl, ga, Ns, retard, decalage )
%BDB Retourne le signal apres passage dans le systeme
%	 Gourdel Thibaut / Perrot Remi
%	 TS113 - Juin 2015
%    TS226 - Decembre 2015 : Rajout du 0.5 (decalage)

% Sous Octave il faut faire attention aux types des variables
Fse = int32(Ts/Te);
Ns_sur = Fse*Ns;

%% =========================== Emetteur ============================== %

% ----------------- Bloc association bits->symbole ------------------- %

% Symboles
ss = sb * 2 - 1;

% -------------------- Filtrage de mise en forme --------------------- %
% Convolution du signal ss(t) et g(t)
% On surechantillonne le signal avant l'envoi sur le canal
ss_sur = zeros(1, Ns_sur);
ss_sur(1:Fse:Ns_sur) = ss;

% // Ne fonctionne pas sous GNU Octave :
% // ss_sur = upsample(ss, Fse);

sl = conv(ss_sur, g) + decalage;
%sl = filter(p, 1, ss_sur) + decalage;

%% ============================= Canal =============================== %

% ------------------------- Filtre du canal -------------------------- %
sl2 = conv(sl, h);

% ------------------------ Bruit additionnel ------------------------- %
yl = sl2 + nl;

%% ========================== Recepteur ============================== %

% ----------------------- Filtre de reception ------------------------ %
rl = conv(yl - decalage, ga);

% ------------------------- Echantillonnage -------------------------- %
%rl_d = downsample(rl, Ts/Te);

% +/- retard a chaque echantillonnage
retard = Fse + retard*Fse*int32(randi(3,1,Ns)-2);

rl_d = rl(retard+(0:Fse:(Ns-1)*Fse));

% -------------------------- Bloc decision --------------------------- %
% ------------------ Bloc association symbole->bits ------------------ %
s = rl_d > 0;

end

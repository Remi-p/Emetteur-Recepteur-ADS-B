function [ s, ss, sl, rl ] = bdb_sync( sb, sigma, Ts, Te, g, h, ga, Ns, decalage, preamb, dec, dec_max, taille_buff )
%BDB_SYNC Retourne le signal apres passage dans le systeme
%   sb : vecteur des bits
%   sigma : pour le bruit gaussien
%   Ts : temps symbole
%   Te : temps echantillonnage
%   g : filtre
%   ga : filtre adapte
%   h : filtre du canal
%   Ns : nombre de symbole
%   preamb : preambule (directement en tant que signal)
%   dec : decalage temporel et frequentiel
%   dec_max : decalage temporel et frequentiel maximal possible
%   taille_buff : taille de la fenetre etudiee

% On choisit directement a l'interieur de la fonction M = 2
M = 2;

dec_t = dec(1);
dec_f = dec(2);

Fse = double(Ts/Te);
Ns_sur = Fse*Ns;

%% =========================== Emetteur ============================== %

% ----------------- Bloc association bits->symbole ------------------- %

% ss = pammod(sb, M, 0); % <= en principe, meme effet ..?
ss = 2 * sb - 1;

% ss
% figure;
% subplot(211);
% stem(sb);
% subplot(212);
% stem(ss);
% pause;
% close;

% -------------------- Filtrage de mise en forme --------------------- %
% Convolution du signal ss(t) et g(t)
% On surechantillonne le signal avant l'envoi sur le canal
ss_sur = zeros(1, Ns_sur);
ss_sur(1:Fse:Ns_sur) = ss;

% // Ne fonctionne pas sous GNU Octave :
% // ss_sur = upsample(ss, Fse);

sl = conv(ss_sur, g) + decalage;
%sl = filter(p, 1, ss_sur) + decalage;

if (length(sl) + dec_t + length(preamb) > taille_buff*Fse)
    error('La taille entree pour le buffer est insuffisante');
end

%% ============================= Canal =============================== %

% Buffer :
buff = zeros(1, taille_buff*Fse);

% ------------------- Desynchronisation temporelle ------------------- %
% dec_t est definit par rapport a Te.
buff(dec_t + (1:length(sl) + length(preamb))) = [preamb sl];

% figure;
% plot(buff, 'b');
% hold on
% plot(((1:dec_t) - dec_t)/dec_t, 'r');
% pause;
% close;

% ----------------- Desynchronisation frequentielle ------------------ %
t = 0:Te:length(buff)*Te-Te;
buff = buff .* exp(-j * 2 * pi * dec_f * t);

% ------------------------- Filtre du canal -------------------------- %
sl_canal = conv(buff, h, 'same');

% ------------------------ Bruit additionnel ------------------------- %
nl = sigma*randn(1, length(sl_canal));
yl = sl_canal + nl;

% ------------------------ Resynchronisation ------------------------- %
% Dans notre cas, on aurait pu implementer cela avec le module ; ainsi,
% on aurait fait disparaitre l'exponentiel.

[dec_t_est dec_f_est] = est_sync(yl, preamb, dec_max, Te, length(sl), Fse);

% Recalage frequentiel
yl = yl .* exp( j * 2 * pi * dec_f_est * t );

% Et temporel (on en profite pour prendre l'absolu)
yl_resynch = abs( yl( dec_t_est + length(preamb) + ...
                        (1:length(sl)) ) );

% % Erreur sur l'estimation de frequence :
% (dec_f_est - dec_f) / dec_f

% figure;
% plot(sl, 'b')
% hold on;
% plot(yl_resynch, 'g' );
% pause;
% close;

%% ========================== Recepteur ============================== %

% ----------------------- Filtre de reception ------------------------ %
rl = conv(yl_resynch - decalage, ga);

% figure;
% hold on;
% stem(ss_sur, 'b');
% plot(rl, 'g');
% pause;
% close;

% ------------------------- Echantillonnage -------------------------- %
indices = Fse + (0:Fse:(Ns-1)*Fse);
rl_d = rl(indices);

% length(ss)
% length(rl_d)
% figure;
% hold on;
% plot(ss, 'b');
% plot(rl_d, 'g');
% % plot(ss - rl_d, 'r');
% pause;
% close;

% -------------------------- Bloc decision --------------------------- %
% ------------------ Bloc association symbole->bits ------------------ %
s = pamdemod(rl_d, M, 0);

% figure;
% stem(s, 'g');
% hold on;
% stem(sb, 'b');
% pause;
% close;

end

%%Hourquebie & Tafroute
clear all;close all;
%% Initialisation des variables
fe = 20*10^6;
Te = 1/fe;
Ds = 1*10^6;
Ts = 1/Ds;
Fse = Ts/Te;
Nb = 112;
N = 512;
EbN0_dB=0:10;
EbN0_lin=10.^(EbN0_dB/10);
erreur=zeros(size(EbN0_dB));
Teb=zeros(size(EbN0_dB));

j=1;
for j=1:1:11
    k=0;
while erreur(j)<100 
    k=k+1;
%% Emetteur

% G�n�ration du message : signal associ� � la s�quence binaire
bk=randi([0,1],1,Nb);
% Association bits->symboles : signal associ� � la s�quence de symbole
ss=2*bk-1;

% Filtre de mise en forme
p = (1/sqrt(Fse))*cat(2,(-1/2)*ones(1,Fse/2),(1/2)*ones(1,Fse/2));

% Normalisation du filtre de mise en forme
pnorm=p/sqrt(sum(p.^2))

% Sur�chantillonnage des symboles
sstilde=upsample(ss,Fse);

% Signal obtenu apr�s le filtre de mise en forme
sl = 0.5*(1/sqrt(Fse))+conv(pnorm,sstilde);

%% Canal AWGN

% R�ponse impulsionnelle du canal de propagation
hl=[1];
% Processus al�atoire Gaussien blanc additif
sigma2=1/(2*EbN0_lin(j));
nl=sqrt(sigma2)*randn(1,length(sl)+length(hl)-1);
% Signal re�u
yl=conv(sl,hl)+nl; 

%% R�cepteur

% Filtre adapt�
p_conj=cat(2,(1/2)*ones(1,Fse/2),(-1/2)*ones(1,Fse/2));
% Normalisation du filtre adapt�
p_conjnorm=p_conj/sqrt(sum(p_conj.^2));
% Signal obtenu apr�s le filtre adapt�
rl=conv(yl,p_conjnorm);
% Sous-�chantillonnage des symboles
rltilde=downsample(rl(Fse:Nb*Fse),Fse);

% D�cision
B=rltilde>0;

% Cumul des erreurs
erreur(j)=erreur(j)+sum(abs(bk(1:length(B))-B));
end
% Taux d'erreur binaire
Teb(j)=erreur(j)/(k*Nb);

end

% Probabilit� d'erreur binaire th�orique
Pb=0.5*erfc(sqrt(EbN0_lin));

% Affichage
figure 
semilogy(EbN0_dB,Teb,'b');
hold on
semilogy(EbN0_dB,Pb,'r');
xlabel('Eb/N0');
ylabel('TEB');
legend('Pb experimental','Pb theorique');
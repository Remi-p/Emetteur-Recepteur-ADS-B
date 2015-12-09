%% Hourquebie & Tafroute
clear all;close all;

%% Initialisation des variables
fe = 20*10^6;
Te = 1/fe;
Ds = 1*10^6;
Ts = 1/Ds;
Fse = Ts/Te;
Nb = 1000;
N = 512;

%% Emetteur

% Génération du message : signal associé à la séquence binaire
bk=randi([0,1],1,Nb);
% Association bits->symboles : signal associé à la séquence de symbole
ss=2*bk-1;

% Filtre de mise en forme
%p = (1/sqrt(Fse))*cat(2,(-1/2)*ones(1,Fse/2),(1/2)*ones(1,Fse/2));
p =(1/sqrt(Fse))*cat(2,(-1/2)*ones(1,Fse/2),(1/2)*ones(1,Fse/2));

% Normalisation du filtre de mise en forme
pnorm=p/sqrt(sum(p.^2))

% Suréchantillonnage des symboles
sstilde=upsample(ss,Fse);

% Signal obtenu après le filtre de mise en forme
sl = 0.5*(1/sqrt(Fse))+conv(pnorm,sstilde);

%% Figures de résultats

%Allure temporelle de sl :
figure
t = [0:Te:25*Ts-Te];
plot(t,sl(1:length(t)));
xlabel('t(s)');
ylabel('sl');

%diagramme de l'oeil de sl
eyediagram(sl(1:100*Fse),100,2*Ts);

%DSP de sl :
f=[-fe/2:fe/N:fe/2-fe/N];
SL=zeros(1,N);
i=0;
k=0;
Npaquet = N*(floor(Nb/N)-1)+2;
for i=2:N:Npaquet
    sltilde=sl(i:i+N-1);
    SLtilde=(1/N^2)*(abs(fft(sltilde,N))).^2;
    SL=SL+SLtilde;
    k=k+1;
end
% DSP expérimentale
DSPslexp = SL/k;
% Construction d'un Dirac
Dirac = zeros(1,N);
Dirac(ceil((N/2)+1))=1;
% DSP théorique
DSPslth = (0.25*Dirac)./Fse+(1/(Fse*Ts)).*(1/Ts).*(((pi.*f.^2).*Ts^4)./4).*((sinc(Ts.*f./2)).^4);
% Affichage
figure 
semilogy(f,fftshift(abs(DSPslexp)),'b');
hold on
semilogy(f(2:end),abs(DSPslth(2:end)),'r');
xlabel('f (Hz)');
ylabel('DSP(W)');
legend('DSP experimentale','DSP theorique');
hold off
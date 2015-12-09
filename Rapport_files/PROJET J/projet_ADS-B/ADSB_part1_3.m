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
Tp=8*10^(-6);
Ntp = Tp/Te;

%% Pr?ambule
sp=[1 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0];
% Sur?chantillonnage du pr?ambule
sptilde=kron(sp,ones(1,Fse/2));%upsample(sp,Fse/2);
% Energie du pr?ambule
E_sp=sqrt(sum(abs(sptilde).^2));
 
j=1;
for j=1:1:11
    j
    k=0;
    while erreur(j)<100 
        k=k+1;
        %% D?fauts:
        % D?lai de propagation
        delta_t=randi([0 100],1,1);
        % D?calage en fr?quence
        delta_f=randi([-1*10^3 1*10^3],1,1);

        %% Emetteur

        % G?n?ration du message : signal associ? ? la s?quence binaire
        bk=randi([0,1],1,Nb);
        % Association bits->symboles : signal associ? ? la s?quence de symbole
        ss=2*bk-1;


        % Filtre de mise en forme
        p = cat(2,(-1/2)*ones(1,Fse/2),(1/2)*ones(1,Fse/2));
        % Normalisation du filtre de mise en forme
        pnorm=p/sqrt(sum(p.^2));
        % Sur?chantillonnage des symboles
        sstilde=upsample(ss,Fse);

        % Signal obtenu apr?s le filtre de mise en forme
        sl = 0.5+conv(pnorm,sstilde);

        % Ajout du pr?ambule
        sl = [sptilde,sl];
        %% Canal
        % R?ponse impulsionnelle du canal de propagation
        hl=[1];

        % D?finition du temps 
        t1 = (0:length(sl)+delta_t-1).*Te;

        % Signal apr?s passage dans le canal
        yl=conv([zeros(1,delta_t),sl.*exp(-1i*2*pi*delta_f*(t1(delta_t+1:end)-Te))],hl);

        % Processus al?atoire Gaussien blanc additif
        sigma2=1/(2*EbN0_lin(j));
        nl=sqrt(sigma2)*randn(1,length(yl));

        % Signal re?u apr?s ajout du bruit
        yl=yl+nl;

        %% R?cepteur

        % Recherche du d?lan de propagation et du d?calage en fr?quence en
        % parcourant tout les cas possibles
        delta_tilde_t=0:100;
        delta_tilde_f=linspace(-1*10^3 , 1*10^3,1000);
        max=0;

        for i1=1:length(delta_tilde_t)
            for i2=1:length(delta_tilde_f)            
                t2= (0:delta_tilde_t(i1)+Ntp).*Te;
                rho(i1,i2)=sum(exp(1i*2*pi*delta_tilde_f(i2)*(t2(delta_tilde_t(i1)+1:delta_tilde_t(i1)+Ntp))).*yl(delta_tilde_t(i1)+1:(delta_tilde_t(i1)+Ntp)).*sptilde)/(E_sp*sqrt(sum(abs(yl(delta_tilde_t(i1)+1:(delta_tilde_t(i1)+Ntp))).^2)));
                rho_abs=abs(rho(i1,i2));
                if rho_abs>max
                    max=rho_abs;
                    delta_t_est=delta_tilde_t(i1);
                    delta_f_est=delta_tilde_f(i2);
                end
            end     
        end
        
        % Filtre adapt? 
        p_conj=cat(2,(1/2)*ones(1,Fse/2),(-1/2)*ones(1,Fse/2));
        % Normalisation du filtre adapté
        p_conjnorm=p_conj/sqrt(sum(p_conj.^2));
        % Signal obtenu apr?s le filtre adapt?
        rl=conv(yl,p_conjnorm);
        % D?finition du temps
        t3 = (0:length(rl)-1).*Te;
        % Synchronisation en fr?quence
        rltilde = rl.*exp(1i*2*pi*delta_f_est*(t3));
        % Synchronisation en d?lai
        rltilde = rltilde((delta_t_est+Ntp):end);
        % Sous-?chantillonnage des symboles
        rltilde = downsample(rltilde(Fse:end),Fse);
        %D?cision
        B=rltilde>0;
        % Cumul des erreurs
        if length(bk)>=length(B)
            erreur(j)=erreur(j)+sum(abs(bk(1:length(B))-B(1:end)))
        else
            erreur(j)=erreur(j)+sum(abs(bk(1:end)-B(1:length(bk))))
        end
        % Taux d'erreur binaire
        Teb(j)=erreur(j)/(k*(Nb));
    end
end
% Probabilit? d'erreur binaire th?orique
Pb=0.5*erfc(sqrt(EbN0_lin));

% Affichage
figure 
semilogy(EbN0_dB,Teb,'b');
hold on
semilogy(EbN0_dB,Pb,'r');
xlabel('Eb/N0');
ylabel('TEB');
legend('Pb experimental','Pb theorique');

%% ADSB Project

%% Initialization
clc
clear all
close all

% JAVA init
import java.net.*;
import java.io.*;
javaaddpath('./javaDataReader');


%% Constants definition
PORT = 1234;
MER_LON = -0.710648; % Longitude de l'a?roport de M?rignac
MER_LAT = 44.836316; % Latitude de l'a?roport de M?rignac

%% Param?tres Utilisateur
Fc = 1090e6; % La fr?quence porteuse
Rs = 4e6; % Le rythme d'?chantillonnage (pas plus de 4Mhz)

antenna = 'TX/RX'; % Port de l'usrp sur lequel est branch?e l'antenne
antenna_gain = 40; % Gain d'antenne

secInBuffer = 0.5; % dur?e du buffer en secondes

%% Autres param?tres
Rb = 1e6;% d?bit binaire
NsB = floor(Rs/Rb); % nombre d'?chantillons par symbole
cplxSamplesInBuffer = secInBuffer*Rs; % dur?e en secondes

%% Affichage de la carte avant de commencer
disp('Chargement de la carte ...')
figure(1);
plot(MER_LON,MER_LAT,'.r','MarkerSize',20);
text(MER_LON+0.05,MER_LAT,'Merignac airport','color','b') % On affiche l'a?roport de M?rignac sur la carte
plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes
xlabel('Longitude en degr?');
ylabel('Lattitude en degr?');
hold on
drawnow

%% Lancement du server
my_server = ServerSocket (PORT); % D?finition d'un server tcp sur le port 1234

% Affichage des lignes de commande pour lancer le client
disp('Pour lancer le client taper le code suivant dans une console :')
disp('----------------------------------------------------------------------------------------------------------------------')
disp(['cd ',strrep(pwd,' ','\ ')])
disp(['python2.7 uhd_adsb_tcp_client.py -s ',num2str(Rs), ' -f ', num2str(Fc), ' -A ' antenna, ' -g ',num2str(antenna_gain)])
disp('----------------------------------------------------------------------------------------------------------------------')
disp('En attente de connexion client...')
socket = my_server.accept; % attente de connexion client
disp('Connexion accept?e')

% Le n?cessaire pour aller lire les paquets re?us par tcp
my_input_stream = socket.getInputStream;
my_data_input_stream = DataInputStream(my_input_stream);
data_reader = DataReader(my_data_input_stream);

disp('En attente de signal...')

% On attend une trame du client
while ~(my_input_stream.available)
end

% Lorsque le buffer est non-vide on commence le traitement
disp('R?ception...')

%% Initilialisations utilisateur =========================================
% ------------------------------------------------------------------------

global verbose;

registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'timeFlag', [], 'cprFlag', [], ...
                  'positions', [], 'velocity', []);

Te = 1/Rs;
Ts = 1/Rb;

Fse = Ts/Te; % Sur-echantillonnage

taille_trame = 112; % Taille d'une trame
preambule = get_preambule(Ts, Fse);

% Taille d'une trame au rythme Te
taille_trame_canal = taille_trame * Fse;

seuil_empirique = 0.78;

% Le decalage est calcule pour chaque trame estimee
% decalage_ampl = 0.5;

% CRC
% On n'utilise pas la fonction propose par MATLAB pour gagner en temps
% d'execution
%h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);
p_gen = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];

% ------------------------------------- Filtres
% p(t) le filtre de mise en forme
p = - ones(1, (Fse)) * 0.5;
p(Fse/2:Fse) = - p(Fse/2:Fse);

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

k = 0;
% ------------------------------------------------------------------------

%% Boucle principale
while my_input_stream.available % tant qu'on re?oit quelque chose on boucle
    
    tic
    
    disp('new buffer')
    int8Buffer = data_reader.readBuffer(cplxSamplesInBuffer*4)'; % Un complexe est cod? sur 2 entiers 16 bits soit 4 octets et readBuffer lit des octets.
    int16Buffer = typecast(int8Buffer,'int16'); % On fait la conversion de 2 entiers 8 bits ? 1 entier 16 bits
    cplxBuffer = double(int16Buffer(1:2:end)) + 1i *double(int16Buffer(2:2:end)); % Les voies I et Q sont entrelac?es, on d?sentrelace pour avoir le buffer complexe.
    
    %% Code utilisateur ==================================================
    % --------------------------------------------------------------------
    
    k = k+1;
    
    fprintf('(Taille du buffer : %i)\n', length(cplxBuffer));
    
    fprintf('Buffer #%i\n\n', k);
    
    % Permet notamment de faire disparaitre le decalage frequentiel
    buffer = abs(cplxBuffer);

    [trames, decalages] = get_trames( buffer, preambule, ...
        Te, Fse, pa, seuil_empirique, taille_trame_canal, p_gen );

    fprintf('Il y a %i pics de correlation.\n', length(decalages));
    fprintf('Nous avons trouve %i trame(s) valide(s).\n', size(trames, 2));

    for i=1:size(trames,2)
        if verbose; cprintf('_blue', 'Trame %i\n', i); end
        registre = bit2registre(trames(:,i), registre, 'CRC', false);
        % 'CRC' = false permet de ne pas recalculer le CRC (deja fait dans
        % get_trames)
    end

%     registre
    if mod(k, 4) == 0
        planes_on_map( registre.positions, registre.adresse );
    end
    
    toc
    % --------------------------------------------------------------------
    
end

%% fermeture des flux
socket.close;
my_input_stream.close;
my_server.close;
disp (['Fin de connexion: ' datestr(now)]);
clc
close all
clear all
       
registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                  'latitude', [], 'longitude', [], 'trajectoire', []);

load('trames_20141120')

for i=1:21
	registre = bit2registre(trames_20141120(:,i), registre);
	registre
end


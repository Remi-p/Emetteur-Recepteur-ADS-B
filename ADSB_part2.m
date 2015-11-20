clc
close all
clear all
       
registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                  'latitude', [], 'longitude', [], 'trajectoire', []);

load('trames_20141120')


bit2registre(trames_20141120(:,1), registre);

test1 = decode_name( '001011001100001101110001110000110010110011100000' )




function [ preambule ] = get_preambule( Ts, Fse )
%GET_PREAMBULE Retourne le preambule en fonction du temps symbole
%   Ts : Temps symbole

% Le preambule correspond au signal donne dans l'enonce. Il n'a pas de lien
% avec la visualisation en termes de bits, meme si on le code avec eux
preamb_faux_bits = [ 1 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 ];
% Temps entre chaque 'faux' bits ci-dessus / Temps symbole
frac_tps_symb = 0.5e-6 / Ts ;
preamb_upsample = upsample(preamb_faux_bits, Fse * frac_tps_symb);
% Soit :
preambule_tmp = conv(preamb_upsample, ones(1, Fse * frac_tps_symb));
% Vis a vis de la convolution, pour retomber sur le signal qu'on cherche
preambule = preambule_tmp(1:end - Fse*frac_tps_symb + 1);

end


function [outdata err] = crc24(h, p)
% crc24 Calcul la valeur du crc
%     renvoie err à 0 s'il n'y a pas d'erreur, 1 sinon
% 	  renvoie la trame sans les bits de crc dans outdata

    % g(X) =  x^24 + x^23 + x^22 + x^21 + x^20 + x^19 + x^18 + x^17 + x^16
    % + x^15 + x^14 + x^13 + x^12 + x^10 + x^3 + 1

    gx = p;
    % P(X) is given input vector
    px = h;
    %Calculate P(x)x^r
    pxr=[px zeros(1,length(gx)-1)];
    % deconvolve  (r), entre pxr y gx
    [c r]=deconv(pxr,gx);

    r=mod(abs(r),2);
    % returncrc-16
    resto=r(length(px)+1:end);

    lenfinal = length(px)-length(gx) + 1;
    
    outdata = transpose(h(:,1:lenfinal));
    if resto == [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
        err = 0;
    else
        err = 1;
    end
end
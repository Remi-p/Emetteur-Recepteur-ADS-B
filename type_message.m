function [ type ] = type_message( FTC )
% type Determine le type de message selon le FTC

% Kind of enum
message = struct('identification',1, ...
				 'surface_pos',2, ...
				 'airborne_pos',3, ...
				 'airborne_vel', 4);

	if (FTC >= 1 & FTC <= 5)
		type = message.identification;
	elseif(FTC >= 5 & FTC <= 8)
		type = message.surface_pos;
	elseif(FTC >= 9 & FTC <= 15)
		type = message.airborne_pos;
	elseif(FTC == 19)
		type = message.airborne_vel;
	elseif(FTC >= 20 & FTC <= 22)
		type = message.airborne_pos;
	else
		type = 0;
	end

end

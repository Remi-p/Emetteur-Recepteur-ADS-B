function [ display_plot, display_velocity ] = display_head( p, head, velocity)
% display_head Affiche la derniere position d'un avion et sa direction par
%              une flèche
    
    x = p(2);
    y = p(1);
    
    u = 0.05*cosd(head);
    v = 0.05*sind(head);

     display_plot = vekplot2(x,y,u,v,2,'blue-');
     
     display_velocity = text(x+0.1, y-0.1,num2str(ceil(velocity)),'color','black');


    
%     display_plot = quiver(x,y,u,v);
%     set(display_plot, 'AutoScale', 'off', ...
%                       'AutoScaleFactor',10 );

%     display_plot = text(p(2),p(1),'\fontsize{22}\color{blue}\uparrow', ...
%                            'horizontalalignment','center', ...
%                            'verticalalignment','bottom');
%     set(display_plot, 'rotation', head);


end
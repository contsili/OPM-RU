figure;
for i=1:size(source.dip.mom,2)
    pause;
    disp(i);
    cla
    ft_plot_dipole(source.dip.pos,source.dip.mom(1:3,i));

    ft_plot_sens(fieldlinealpha1, 'label', 'no', 'axes', 0, 'orientation', 0) % , 'chantype', 'megmag')
    hold on
    
    
    [x,y,z] = sphere;
    x = x * singlesphere.r + singlesphere.o(1);
    y = y * singlesphere.r + singlesphere.o(2);
    z = z * singlesphere.r + singlesphere.o(3);
    h=surf(x,y,z);
    set(h, 'FaceAlpha', 0.03);
    axis equal;
    xlabel('x');
    ylabel('y');
    zlabel('z');

    view(170,0);

    drawnow %2nd way: use movie()
end


%ft_read_event
%leadfield and units 
%check orientation with movie


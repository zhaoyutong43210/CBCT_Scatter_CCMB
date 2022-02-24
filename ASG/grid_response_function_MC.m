function grid_response_function_MC(geopath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is for 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
if nargin <1 
   geopath = 'D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a\'; 
elseif nargin == 1
   %if isstr(geopath)
end
geoinfo = load([geopath,'\Varian_TIGRE_Recon.mat']);

geo = geoinfo.geo;

mygrid.X1 = [-geo.sDetector(2)/2:10/60:geo.sDetector(2)/2] + geo.offDetector(2);
mygrid.X2 = mygrid.X1 - 1.3/geo.DSD.*mygrid.X1;
mygrid.X = [mygrid.X1;mygrid.X2];
mygrid.Z = [zeros(size(mygrid.X2));1.3*ones(size(mygrid.X2))];
mygrid.theta = atan(geo.DSD./mygrid.X1);
%plot(mygrid.X,mygrid.Z,'b-')
xx = linspace(-geo.sDetector(1)/2,geo.sDetector(1)/2,geo.nDetector(1))+geo.offDetector(1);
yy = linspace(-geo.sDetector(2)/2,geo.sDetector(2)/2,geo.nDetector(2))+geo.offDetector(2);
[dectx,decty] = meshgrid(xx,yy);

xsource = [0 0 geo.DSD];

% lead attenuation in total
muPB = 89 * 11.35; 
%  (mass energy-absorption coefficient) cm^2/g * (lead mass density) g/cm^3 => cm^-1
%  the data should be within the 0 - 125KeV range
% scatter cross section 
scPB = (14) * 11.35;
% %%%%%%%%%%%%%%%%


% plot detector plane
Detector_planeX = [-geo.sDetector(1)/2,-geo.sDetector(1)/2,geo.sDetector(1)/2,geo.sDetector(1)/2,-geo.sDetector(1)/2]+geo.offDetector(1);
Detector_planeY = [-geo.sDetector(2)/2,geo.sDetector(2)/2,geo.sDetector(2)/2,-geo.sDetector(2)/2,-geo.sDetector(2)/2]+geo.offDetector(2);
Detector_planeZ = [0,0,0,0,0];
plot3(Detector_planeX,Detector_planeY,Detector_planeZ,'s-');hold on; grid on 
xlabel('x')
ylabel('y')
daspect([1 1 1])



    %tic
%pidx = 1;


simu_n = 1e2;
DVangle = zeros(1,simu_n);
trans = zeros(1,simu_n);



for nloop = 1:simu_n

    stat_n = 1e3;

transmission = NaN(stat_n,1);

for nn = 1:stat_n
    x = xx(randi(length(xx)));
    y = yy(randi(length(yy)));

    ptarget = [x y 0];
    ray_vector = [ptarget-xsource]; % solid blue line - primary photon
    


    
    idx = randi(length(xx));
    idy = randi(length(yy));
    
    DVangle(nloop) = atan(xx(idx)/geo.DSD)-atan(x/geo.DSD); % diff vertical   (z-x plane)
    DTangle(nloop) = atan(yy(idy)/geo.DSD)-atan(y/geo.DSD); % diff transverse (z-y plane)
 

%sidx = 100;
    xs = xx(1) + (rand-0.5)*geo.dDetector(1);
    ys = yy(1) + (rand-0.5)*geo.dDetector(2);

    
starget = [xs ys 0];
scatterh = geo.DSD-geo.DSO + (rand-0.5)*geo.sVoxel(3);
rto = scatterh./geo.DSD;
ssource = ptarget - ray_vector.*rto; 

scatter_vector = [starget - ssource]; % solid red line - scattered photon

scatter_gridtop = starget+scatter_vector/(scatter_vector(3))*1.3;
trans_vector = [starget-xsource];  % dashed red line - scattered photon's ASG strip direction

theta = abs(atan(trans_vector(3)/trans_vector(2)) - atan(scatter_vector(3)/scatter_vector(2)));

% for n = 1:length(dectx(:))
%     
% end


%% plot primary X-ray photon
ptarget = ptarget-ray_vector*0.333;
plot3(xsource(1),xsource(2),xsource(3),'bo','Linewidth',3);hold on
plot3([ptarget(1),xsource(1)],[ptarget(2),xsource(2)],[ptarget(3),xsource(3)],'b-')
%% plot scattered X-ray photon
plot3(ssource(1),ssource(2),ssource(3),'ro');hold on
plot3([starget(1),ssource(1)],[starget(2),ssource(2)],[starget(3),ssource(3)],'r-')
% plot the primary direction on the scattered target
plot3([starget(1),xsource(1)],[starget(2),xsource(2)],[starget(3),xsource(3)],'r--')
%
%transmission = caltrans2(scatter_vector,trans_vector);



scatter_ray = [[starget(1);scatter_gridtop(1)];[starget(3);scatter_gridtop(3)]]; % x1,x2 z1,z2
scatter_ray3 = [starget;scatter_gridtop];


mygrid.Cor = [mygrid.X;mygrid.Z]; % x1,x2 z1,z2

[n,ind] = count_inter(scatter_ray,mygrid.Cor);

    %if theta > pi/2
        theta(theta > pi/2) = theta(theta > pi/2)-pi;
    %end
angle_scatter(nn) = abs(wrapToPi(theta));
%angle_scatter = atan2(norm(cross(ray_vector,scatter_vector)), dot(ray_vector,scatter_vector));
    if n>0
        leadl = cal_lead(scatter_vector,mygrid.theta(ind))/10;
        leadl(leadl>0.037) = 0.037; % in cm
        
        % only the first order scattering is considered
        transmission(nn) = exp(-muPB*sum(leadl)) + (1-exp(-muPB*leadl(1)))*exp(-scPB*leadl(1));
        %transmission(nn) = exp(-muPB*sum(leadl))+exp(-scPB*sum(leadl));
        
    else 
        transmission(nn) = 1;
    end 

%         if transmission(nn) <0.05
%            transmission(nn)
%         end 
        
%toc
end

        trans(nloop) = mean(transmission,'omitnan');
        

    if (nloop/10-round(nloop/10))==0
        plot(rad2deg(abs(DVangle)),trans,'ko'); %hold on
        drawnow
        disp(['simulation % = ',num2str(nloop/simu_n)])
    end

end
save('ASG_DayDance_model3.mat')
end


function [n,ind] = count_inter(scatter_ray,grid_cor)
% step 1 : fast reject examination (only in x-direction due to our application)
iteridx = ~(max(scatter_ray(1:2))<min(grid_cor(1:2,:)) | min(scatter_ray(1:2))>max(grid_cor(1:2,:)));

% step 2: cross product examination 
%  plot(scatter_ray(1:2),scatter_ray(3:4),'ro-')
%  plot(grid_cor(1:2,iteridx),grid_cor(3:4,iteridx),'b*--')

CD = [scatter_ray(2)-scatter_ray(1);scatter_ray(4)-scatter_ray(3)];
%AB = [grid_cor(2,:)-grid_cor(1,:);grid_cor(4,:)-grid_cor(3,:)];

CA =  [grid_cor(2,iteridx)-scatter_ray(1);grid_cor(4,iteridx)-scatter_ray(3)];
CB =  [grid_cor(1,iteridx)-scatter_ray(1);grid_cor(3,iteridx)-scatter_ray(3)];

id = mycross(CA,CD).*mycross(CB,CD) <=0;

m = find(iteridx);
ind = m(id);
n = length(ind);

%plot(grid_cor(1:2,ind),grid_cor(3:4,ind),'r-','Linewidth',3);
end

function C = mycross(A,B)
C = A(1,:)*B(2,:)-A(2,:)*B(1,:);
end

function L = cal_lead(scatter_ray3,mygrid_angle)
scatter_anglexz = atan(scatter_ray3(3)/scatter_ray3(1));
%scatter_anglexy = atan(scatter_ray3(3)/scatter_ray3(2));

theta = mygrid_angle - scatter_anglexz;
Langle = pi - mygrid_angle;

Lxz = 0.036./sin(theta).*sin(Langle);
Ly = Lxz*sin(scatter_anglexz).*scatter_ray3(2)/scatter_ray3(3);
L = sqrt(Lxz.^2 + Ly.^2);
end
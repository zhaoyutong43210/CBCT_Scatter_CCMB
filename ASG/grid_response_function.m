function grid_response_function
clf
load('ASG_DayDance_model3.mat')

inds = DVangle<0;

Ag = -DVangle(inds);

T = trans(inds);

subplot(1,2,1)
plot(rad2deg(Ag),T,'.')

ylim([0 1])
ylabel('Tranmission')
xlabel('angle (^o)')
zz = linspace(0,max(Ag),1e2+1);
Ta = zeros(1,1e2+1); 
for n = 1:length(zz)-1
    
    m1 = zz(n);
    m2 = zz(n+1);
    
    ind = (Ag>m1 & Ag<m2);
    
    Ta(n) = mean(T(ind));
end 

xx  = rad2deg(zz(2:end)-(zz(2)-zz(1))/2);
yy = Ta(1:end-1);
hold on 
plot(rad2deg(zz(2:end)-(zz(2)-zz(1))/2),yy,'r.-')
legend('Monte-Carlo method','Average')
subplot(1,2,2)
plot(xx,yy,'bo-')

hold on 
GRF
xlabel('angle (^o)')
ylabel('Transmission')
legend('Simulation','linear model')
set(gca,'Fontsize',16)
end

function  GRF

theta_max = atan(360/1500)+ atan(40/1500);
theta = linspace(0,theta_max,1e4);

cover_ratio = 10*tan(theta)*1.85;
cover_ratio(cover_ratio>1) = 1;
    
scatter_level = 0.325;
transmission = (1-cover_ratio)+(cover_ratio)*scatter_level;
plot(rad2deg(theta),transmission,'Linewidth',3)
ylim([0 1])
grid on
xlim([0 10])
end
% DESCRIPTION:
% This script tests the implementation of the ALVA LET model, calculating 
% strains with depth for a multilayered pavement subjected to two circular
% loads utilizing the method proposed. The results are compared to the 
% computer programme ELLEA1.
% -------------------------------------------------------------------------
% References
% -------------------------------------------------------------------------
% Levenberg, E. (2016a). ELLEA1: Isotropic layered elasticity in excel: 
% Pavement analysis tool for students and engineers.

clear all, close all, clc
% -------------------------------------------------------------------------
% Select response analysis type
% -------------------------------------------------------------------------
alva.analysis = 'Full';
% 1) 'Full'     : Conventional full integration with one-step Richardson
%                 extrapolation (for improved convergence near surface) 
%                 applied for evaluation of displacements and stresses
% 2) 'PolFit'   : Use polynomial fit technique to reduce integral length
%                 according to Andersen et al. (2018) for evaluation of
%                 surface displacements

% -------------------------------------------------------------------------
% Select interface 
% -------------------------------------------------------------------------
alva.bond = 'Bonded';
% 1) 'Bonded'       : Full bonding between layers
% 2) 'Slip'         : Interface bonding factor
% 3) 'Frictionless' : No bonding between layers

% -------------------------------------------------------------------------
% Numerical parameters
% -------------------------------------------------------------------------
alva.N  = 300;  % Number of Bessel zero points in numerical integration
alva.n  = 30;   % Number of Gauss points points between zero points.

% -------------------------------------------------------------------------
% Pavement material properties (minimum two layers required)
% -------------------------------------------------------------------------
alva.zi = [150 750];         % Depth of first n-1 layers from the 
                             % surface [mm]: last z = inf, and should not 
                             % be added NB: zi(i) > zi(i-1) > z(i-2)...
alva.E  = [3000 200 40];     % Layer Young's moduli [MPa]
alva.nu = [0.30 0.35 0.40];  % Layer Poisson's ratio [-]
alva.kh = [1e9 1e9];         % Interface bonding/horizontal spring [MPa/mm]

% -------------------------------------------------------------------------
% Load configuration
% -------------------------------------------------------------------------
alva.q  = [1.1
           1.1];         % Load pressure [MPa] (uniform vertical pressure)
alva.a  = [150
           150];         % Load radii [mm] (circular load)
alva.Xl = [0.0 -150
           0.0  150];    % Load positions [mm]: [x1 y1; x2 y2;..xi yi]; 

% -------------------------------------------------------------------------
% Location of evaluation points: [x1 y1 z1; x2 y2 z2;..]
% -------------------------------------------------------------------------
alva.Xd = [10      20      0; 10      20     10; 10      20      20;    
           10      20     30; 10      20     40; 10      20      50;	
           10      20     75; 10      20	100; 10      20     150;
           10      20    200; 10      20	250; 10      20     300; 
           10      20    350; 10      20    400; 10      20     450;
           10      20    500; 10      20    750; 10      20    1000];
    
% -------------------------------------------------------------------------
% Initialize system and get response
% -------------------------------------------------------------------------
alva = init_LET(alva);

% Displacements
ux    = alva.ux;
uy    = alva.uy;   % [mm]
uz    = alva.uz;   % [mm]

% Stresses
sigx  = alva.sigx;  % [MPa]
sigy  = alva.sigy;  % [MPa]
sigz  = alva.sigz;  % [MPa]
sigxy = alva.sigxy; % [MPa]
sigyz = alva.sigyz; % [MPa]
sigxz = alva.sigxz; % [MPa]

% Strains
epsx  = alva.epsx.*1e6;  % [micro strain]
epsy  = alva.epsy.*1e6;  % [micro strain]
epsz  = alva.epsz.*1e6;  % [micro strain]
epsxy = alva.epsxy.*1e6; % [micro strain]
epsyz = alva.epsyz.*1e6; % [micro strain]
epsxz = alva.epsxz.*1e6; % [micro strain]

% -------------------------------------------------------------------------
% Validation
% -------------------------------------------------------------------------

% Validation using independent software
alva.validation = 'halfspace_shear_strain';  % select dual wheel load and 
                                        % shear stresses with depth        
ellea           = validation_let(alva); % Collumns: [length/depth,epsx
                                        % ,epsy,epsx,epsxy,epszy,epszx] 

% -------------------------------------------------------------------------
% Plotting
% -------------------------------------------------------------------------

figure, title('Shear strain (x=10, y=20)');
hold on, grid on
plot(epsxy,alva.Xd(:,3),':ks','LineWidth',1.25,'MarkerSize',5)
hold on
plot(epsyz,alva.Xd(:,3),':ko','LineWidth',1.25,'MarkerSize',5)
hold on
plot(epsxz,alva.Xd(:,3),':k^','LineWidth',1.25,'MarkerSize',5)
hold on
plot(ellea(:,5),ellea(:,1),':b+','LineWidth',1,'MarkerSize',5)
hold on
plot(ellea(:,6),ellea(:,1),':g+','LineWidth',1,'MarkerSize',5)
hold on
plot(ellea(:,7),ellea(:,1),':r+','LineWidth',1,'MarkerSize',5)
hold on
set(gca,'FontSize',9)
legend({'ALVA - epsxy','ALVA - epsyz','ALVA - epsxz',...
    'ELLEA1 - epsxy','ELLEA1 - epsyz','ELLEA1 - epsxz'},...
    'Location','SouthEast')
axis ij
xlabel('Strain, \epsilon [-]')
ylabel('Depth, z-axis [mm]')
hold off

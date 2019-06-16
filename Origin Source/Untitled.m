clear all
close all
%%
clear
Y = [6.4, 6.45, 6.75, 11.6; 5.75, 5.75, 6.1, 11.6; 5.4, 5.4, 5.6, 11.6; 5.05, 5.05, 5.2, 11.6]/11.65;
bar(Y,1);grid on;set(gca,'FontSize',16);
xlabel('Required Probability of Cycle Slip Missed Detection','FontSize',16);ylabel('Service Availability','FontSize',16);title('Service Availability by Required Probability of Missed Detection','FontSize',16)
text(1,0.1,'1e-2','FontSize',16);text(1,0.1,'1e-3','FontSize',16);text(1,0.1,'1e-4','FontSize',16);text(1,0.1,'1e-5','FontSize',16);
text(1,0.1,'0.95','FontSize',16);text(1,0.1,'0.96','FontSize',16);text(1,0.1,'0.97','FontSize',16);text(1,0.1,'0.98','FontSize',16);text(1,0.1,'0.99','FontSize',16);
text(1,0.1,'     ','FontSize',16);text(1,0.1,'     ','FontSize',16);text(1,0.1,'     ','FontSize',16);text(1,0.1,'     ','FontSize',16);text(1,0.1,'     ','FontSize',16);
legend('General Failure', 'Half Cycle', 'Full Cycle', 'Raw Avail.');
clear
X1 = [0.5, 0.75, 1, 1.25, 1.5, 1.75];
Y1 = [10.8, 11.1, 14.6, 14.8; 8.4, 8.4, 8.9, 14.8; 6, 6, 6.3, 14.8; 3.95, 4.4, 4.6, 14.8; 1.65, 1.65, 1.75, 14.8; 0.15, 0.15, 0.15, 14.8]/14.85;
Y1_1 = Y1(:,1)';Y1_2 = Y1(:,2)';Y1_3 = Y1(:,3)';Y1_4 = Y1(:,4)';
figure;hold on;grid on;set(gca, 'FontSize', 16);line(X1, Y1_1, 'LineStyle', ':', 'Marker', 'd');line(X1, Y1_2, 'LineStyle', '-', 'Marker', 's');line(X1, Y1_3, 'LineStyle', '--', 'Marker', 'o');line(X1, Y1_4, 'LineStyle', '-', 'LineWidth', 3);
xlabel('\sigma (cm)','FontSize',16);ylabel('Service Availability','FontSize',16);title('Service Availability by Standard Deviation of Measurement Error','FontSize',16)
xlim([0.5, 1.75]);legend('General Failure', 'Half Cycle', 'Full Cycle', 'Raw Avail.');
line([1.75, 1.75], [0, 1], 'color','k');line([0.5, 1.75], [1, 1], 'color','k');
text(0.435,0.22222,'           ','FontSize',16);text(0.435,0.44444,'           ','FontSize',16);text(0.435,0.66666,'           ','FontSize',16);text(0.435,0.88888,'           ','FontSize',16);
text(0.434,0.11111,'    0.96','FontSize',16);text(0.434,0.33333,'    0.97','FontSize',16);text(0.434,0.55555,'    0.98','FontSize',16);text(0.434,0.77777,'    0.99','FontSize',16);
xlabel('\sigma (cm)','FontSize',16);ylabel('Service Availability','FontSize',16);title('Service Availability by Standard Deviation of Measurement Error','FontSize',16)

%%
X1 = [0, 10, 20, 30, 40, 50];
Y1 = [ 0,  0,  0,  0; ...
       (1.3/5.3)*1/5, (1.65/5.3)*1/5, (2.2/5.3)*1/5, (3.3/5.3)*1/5; ...
       (1.3/5.3)*2/5, (1.65/5.3)*2/5, (2.2/5.3)*2/5, (3.3/5.3)*2/5; ...
       (1.3/5.3)*3/5, (1.65/5.3)*3/5, (2.2/5.3)*3/5, (3.3/5.3)*3/5; ...
       (1.3/5.3)*4/5, (1.65/5.3)*4/5, (2.2/5.3)*4/5, (3.3/5.3)*4/5; ...
       (1.3/5.3)*5/5, (1.65/5.3)*5/5, (2.2/5.3)*5/5, (3.3/5.3)*5/5]*20;
Y1_1 = Y1(:,1)';Y1_2 = Y1(:,2)';Y1_3 = Y1(:,3)';Y1_4 = Y1(:,4)';
figure;hold on;grid on;set(gca, 'FontSize', 16);
line(X1, Y1_1, 'LineStyle', '-', 'Marker', 'o');
line(X1, Y1_2, 'LineStyle', '-', 'Marker', '*');
line(X1, Y1_3, 'LineStyle', '-', 'Marker', 's');
line(X1, Y1_4, 'LineStyle', '-', 'Marker', 'd');
axis([0, 50, 0, 20]);legend('\alpha = 3', '\alpha = 5', '\alpha = 7', '\alpha = 9');
line([50, 50], [0, 20], 'color','k');line([0, 50], [19.999, 19.999], 'color','k');
xlabel('x_0 (nmi)','FontSize',16);ylabel('x_1 (nmi)','FontSize',16);title('< Limit Case 1 >','FontSize',16)

%%
X1 = [0, 10, 20, 30, 40, 50];
Y1 = [ 0,  0,  0,  0; ...
       (1.45/5.7)*1/5, (1.9/5.7)*1/5, (2.6/5.7)*1/5, (4.35/5.7)*1/5; ...
       (1.45/5.7)*2/5, (1.9/5.7)*2/5, (2.6/5.7)*2/5, (4.35/5.7)*2/5; ...
       (1.45/5.7)*3/5, (1.9/5.7)*3/5, (2.6/5.7)*3/5, (4.35/5.7)*3/5; ...
       (1.45/5.7)*4/5, (1.9/5.7)*4/5, (2.6/5.7)*4/5, (4.35/5.7)*4/5; ...
       (1.45/5.7)*5/5, (1.9/5.7)*5/5, (2.6/5.7)*5/5, (4.35/5.7)*5/5]*20;
Y1_1 = Y1(:,1)';Y1_2 = Y1(:,2)';Y1_3 = Y1(:,3)';Y1_4 = Y1(:,4)';
figure;hold on;grid on;set(gca, 'FontSize', 16);
line(X1, Y1_1, 'LineStyle', '-', 'Marker', 'o');
line(X1, Y1_2, 'LineStyle', '-', 'Marker', '*');
line(X1, Y1_3, 'LineStyle', '-', 'Marker', 's');
line(X1, Y1_4, 'LineStyle', '-', 'Marker', 'd');
axis([0, 50, 0, 20]);
legend('\alpha = 3', '\alpha = 5', '\alpha = 7', '\alpha = 9');
line([50, 50], [0, 20], 'color','k');line([0, 50], [19.999, 19.999], 'color','k');
xlabel('x_0 (nmi)','FontSize',16);ylabel('x_1 (nmi)','FontSize',16);title('< Limit Case 2 >','FontSize',16)

%%
X1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
Y1 = [((392.5-15.1)/392.5), ((392.5-14.6)/392.5), ((392.5-10.9)/392.5); ...
      ((392.5-7.4 )/392.5), ((392.5-7.05)/392.5), ((392.5-6.8 )/392.5); ...
      ((392.5-4.5 )/392.5), ((392.5-4.25)/392.5), ((392.5-4   )/392.5); ...
      ((392.5-2.75)/392.5), ((392.5-2.55)/392.5), ((392.5-2.35)/392.5); ...
      ((392.5-1.05)/392.5), ((392.5-0.85)/392.5), ((392.5-0.7 )/392.5); ...
      ((392.5-0.5 )/392.5), ((392.5-0.3 )/392.5), ((392.5-0.2 )/392.5); ...
      ((392.5-0.5 )/392.5), ((392.5-0.3 )/392.5), ((392.5-0.2 )/392.5); ...
      ((392.5-0.5 )/392.5), ((392.5-0.3 )/392.5), ((392.5-0.2)/392.5); ...
      ((392.5-0.5 )/392.5), ((392.5-0.3 )/392.5), ((392.5-0.2 )/392.5); ...
      ((392.5-0.5 )/392.5), ((392.5-0.3 )/392.5), ((392.5-0.2 )/392.5)];
Y1_1 = Y1(:,1)';Y1_2 = Y1(:,2)';Y1_3 = Y1(:,3)';
figure;hold on;grid on;set(gca, 'FontSize', 16);
line(X1, Y1_1, 'LineStyle', '-', 'Marker', 's');
line(X1, Y1_2, 'LineStyle', '-', 'Marker', 'o');
line(X1, Y1_3, 'LineStyle', '-', 'Marker', 'd');
axis([1, 10, 0.96, 1]);
line([1, 10], [0.99999, 0.99999], 'color','k');line([10, 10], [0.96, 1], 'color','k');
legend('mask = 5', 'mask = 7.5', 'mask = 10');
xlabel('\alpha','FontSize',16);ylabel('Availability','FontSize',16);title('< Service Availability >','FontSize',16)

%%
X1 = [0.01, 0.0108, 0.0119, 0.0128, 0.0142, 0.0155, 0.0165, 0.0181, 0.0198, 0.0215, 0.0235, 0.026];
Y1 = [((294-0.25)/294), ((294-0.10)/294), ((294-0.05)/294); ...
      ((294-0.27)/294), ((294-0.12)/294), ((294-0.05)/294); ...
      ((294-0.30)/294), ((294-0.15)/294), ((294-0.10)/294); ...
      ((294-0.39)/294), ((294-0.20)/294), ((294-0.12)/294); ...
      ((294-0.40)/294), ((294-0.25)/294), ((294-0.15)/294); ...
      ((294-2.10)/294), ((294-0.50)/294), ((294-0.20)/294); ...
      ((294-6.50)/294), ((294-2.85)/294), ((294-0.60)/294); ...
      ((294-12.9)/294), ((294-4.30)/294), ((294-0.80)/294); ...
      ((294-20.0)/294), ((294-8.85)/294), ((294-3.40)/294); ...
      ((294-20.0)/294), ((294-16.5)/294), ((294-6.20)/294); ...
      ((294-20.0)/294), ((294-16.5)/294), ((294-12.3)/294); ...
      ((294-20.0)/294), ((294-16.5)/294), ((294-20.0)/294)];
Y1_1 = Y1(:,1)';Y1_2 = Y1(:,2)';Y1_3 = Y1(:,3)';
figure;hold on;grid on;set(gca, 'FontSize', 16);
line(X1, Y1_1, 'LineStyle', '-', 'Marker', 's');
line(X1, Y1_2, 'LineStyle', '-', 'Marker', 'o');
line(X1, Y1_3, 'LineStyle', '-', 'Marker', 'd');
axis([0.01, 0.03, 0.95, 1]);
line([0.01, 0.03], [0.99999, 0.99999], 'color','k');line([0.03, 0.03], [0.95, 1], 'color','k');
legend('mask = 5', 'mask = 7.5', 'mask = 10');
xlabel('\beta','FontSize',16);ylabel('Availability','FontSize',16);title('< Availability >','FontSize',16)

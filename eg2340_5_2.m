clc;
clear all;
load = [22 22 18 15 18 20 29 41 46 72 75 92 81 94 90 97 80 74 60 67 75 66 29 28];
wind = [31 32 43 48 47 36 6 8 12 18 26 39 45 45 50 46 41 44 41 50 49 31 31 50];

diesel_inst = 100;
wind_inst = 50;
load_inst = 100;
dump_inst = 100;
bat_inst = 100;

diesel_en_flow = zeros(1,24);

for i=1:24
    diesel_en_flow(i) = load(i)*1;
end

for i=1:24
    fprintf('Hour %d\t%.2f\n',i,diesel_en_flow(i));
end
fprintf('\nFuel used is %.2f\n', sum(diesel_en_flow.*0.25)+3*24+1);
diesel_must_run=1;
diesel_min = 30;
bat_min = 20;
bat_max = 90;
bat_val = zeros(1,24);
bat_initial = 30;

diesel_en_flow = zeros(1,24);
bat_en_flow = zeros(1,24);
dump_en_flow = zeros(1,24);

for i=1:24
    if(i==1)
        bat_soc = bat_initial;
    else
        bat_soc = bat_val(i-1);
    end
    if(load(i) <= (diesel_min + wind(i)))
        excess = diesel_min + wind(i) - load(i);
        if(excess > (bat_max - bat_soc))
            bat_en_flow(i) = bat_max - bat_soc;
            bat_val(i) = bat_max;
            excess = excess - bat_max + bat_soc;
        elseif(excess <= (bat_max - bat_soc))
            bat_val(i) = bat_soc + excess;
            bat_en_flow(i) = excess;
            excess=0;
        end
        if(excess > 0)
           dump_en_flow(i) = excess;
        end
        diesel_en_flow(i) = diesel_min;
    elseif (load(i) > (diesel_min + wind(i)) && load(i) <= (diesel_min + wind(i) + bat_soc - bat_min))
            excess = diesel_min + wind(i) - load(i);
            bat_val(i) = bat_soc + excess;
            bat_en_flow(i) = excess;
            diesel_en_flow(i) = diesel_min;        
    elseif(load(i)> (diesel_min + wind(i) + bat_soc - bat_min))
            excess = load(i) - (diesel_min + wind(i) + bat_soc - bat_min);
            bat_en_flow(i) = bat_min - bat_soc;
            bat_val(i) = bat_min;
            diesel_en_flow(i) = diesel_min + excess;
    else
        disp('Something wrong');
    end
end

fprintf('\nLoad\tWind\tDiesel Flow\tBattery Flow\tBattery Value\tDump Load\n');
for i=1:24
    fprintf('%.2f\t%.2f\t\t%.2f\t\t%.2f\t\t\t%.2f\t\t\t%.2f\n',load(i),wind(i),diesel_en_flow(i),bat_en_flow(i),bat_val(i),dump_en_flow(i));
end

fprintf('\nFuel used is %.2f\n', sum(diesel_en_flow.*0.25)+3*nnz(diesel_en_flow)+1);

diesel_min = 30;
bat_min = 20;
bat_max = 90;
bat_val = zeros(1,24);
bat_initial = 30;

diesel_en_flow = zeros(1,24);
bat_en_flow = zeros(1,24);
dump_en_flow = zeros(1,24);

fprintf('\nLoad\tWind\tDiesel Flow\tBattery Flow\tBattery Value\tDump Load\n');
for i=1:24
    if(i==1)
        bat_soc = bat_initial;
    else
        bat_soc = bat_val(i-1);
    end
    bat_av = bat_soc - bat_min;
    if(load(i) <= (bat_av+ wind(i)))
        excess = wind(i) - load(i);
        if((bat_soc+excess) > bat_max)
            bat_val(i) = bat_max;
            bat_en_flow(i) = bat_max - bat_soc;
            dump_en_flow(i) = excess - (bat_max - bat_soc);
        else
            bat_val(i) = bat_soc + excess;
            bat_en_flow(i) = excess; 
        end
    elseif (load(i) > (bat_av + wind(i)))
            excess = load(i) - wind(i);
            bat_buf = bat_max - bat_soc;
            if((excess + bat_buf) > diesel_inst)
                diesel_en_flow(i) = diesel_inst;
                bat_en_flow(i) = diesel_inst - excess;
                bat_val(i) = bat_soc + bat_en_flow(i);
            else
                diesel_en_flow(i) = excess + bat_buf;
                bat_val(i) = bat_max;
                bat_en_flow(i) = bat_buf;
            end
    else
        disp('Something wrong');
    end
    fprintf('%.2f\t%.2f\t\t%.2f\t\t%.2f\t\t\t%.2f\t\t\t%.2f\n',load(i),wind(i),diesel_en_flow(i),bat_en_flow(i),bat_val(i),dump_en_flow(i));
end
fprintf('\nFuel used is %.2f\n', sum(diesel_en_flow.*0.25)+3*nnz(diesel_en_flow)+1);
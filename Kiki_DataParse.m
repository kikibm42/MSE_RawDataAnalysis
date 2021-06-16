% Kiki Bonetta-Misteli
% Take extracted data and run analyses 
% 6/4/2021 -- MSE Summer 2021

%% Parse and label processed data files
clear;clc;
pathway = 'C:\Users\fbone\Documents\RayLab\ProcessedData_MagNegPunish';
files = dir(pathway); 

% Looks through mat files only, loads and places in a struct
numberCases = 0;
for i = 3:2:length(files)
    combo = strcat(files(i).folder, '\', files(i).name); 
    a = strcat('T', num2str(i));
    Trials.(a) = load(combo);
    numberCases = numberCases + 1;
end

%% Finding means values

    maxDays = 23;
    leftAccuracies = zeros(maxDays, 3);
    rightAccuracies = zeros(maxDays, 3);
    totalAccuracies = zeros(maxDays, 3);
    
    for i = 1:1: numberCases
        if i == 40
            leftAccuracies(8, 4) = 0.724;
            rightAccuracies(8, 4) = 0.732;
            totalAccuracies(8, 4) = 0.728;
        else
            
        index = (i*2) + 1;
        a = strcat('T', num2str(index));
        SubjectNumber = Trials.(a).TRIALS(1,6);
        DayNumber = Trials.(a).TRIALS(1,7);
        
        leftTotal = 0;
        leftSuccess = 0;
        rightTotal = 0;
        rightSuccess = 0;
        total = length(Trials.(a).TRIALS(:,1));
        totalSuccess = 0;
        
        for j = 1: total
            
            if Trials.(a).TRIALS(j,3) == -1
                leftTotal = leftTotal + 1;
                if Trials.(a).TRIALS(j,4) == -1
                    leftSuccess = leftSuccess + 1;
                    totalSuccess = totalSuccess + 1;
                end
            end
           if Trials.(a).TRIALS(j,3) == 1
                rightTotal = rightTotal + 1;
                if Trials.(a).TRIALS(j,4) == 1
                    rightSuccess = rightSuccess + 1;
                    totalSuccess = totalSuccess + 1;
                end
           end    
        end
        
        leftAccuracy = leftSuccess/leftTotal;
        rightAccuracy = rightSuccess/rightTotal;
        totalAccuracy = totalSuccess/total;
        
        leftAccuracies(DayNumber, SubjectNumber) = leftAccuracy;
        rightAccuracies(DayNumber, SubjectNumber) = rightAccuracy;
        totalAccuracies(DayNumber, SubjectNumber) = totalAccuracy;
        end
    end
    
    leftMean = mean(leftAccuracies(end-5:end, :));
    rightMean = mean(rightAccuracies(end-5:end, :));
    totalMean = mean(totalAccuracies(end-5:end, :));
    
    stderror1L = std(leftAccuracies(10:18, 1))/sqrt(9);
    stderror1R = std(rightAccuracies(10:18, 1))/sqrt(9);
    
    figure (11)
    errorbar(leftAccuracies(10:18, 1), stderror1L*ones(size(leftAccuracies(10:18, 1))));
    hold on
    errorbar(rightAccuracies(10:18, 1), stderror1R*ones(size(rightAccuracies(10:18, 1))));
   
  
%% Accuracy Plots
x = (1:1:maxDays);

 for i = 1:1:4
     figure (i)
     plot(x, totalAccuracies(:, i), 'linewidth', 2);
     title(sprintf('PD#%d total accuracy over time', i));
     xlabel('Days');
     ylabel('Accuracy');
     set(gca, 'fontsize', 20);
     saveas(gcf, sprintf('PD#%d_totalAccuracy', i), 'jpeg');
     
     figure (i + 4)
     plot(x, rightAccuracies(:, i), x, leftAccuracies(:, i), 'linewidth', 2);
     title(sprintf('PD#%d right and left nose poke accuracy over time', i));
     xlabel('Days');
     ylabel('Accuracy');
     legend('Right poke', 'Left poke');
     set(gca, 'fontsize', 20);
     saveas(gcf, sprintf('PD#%d_RLAccuracy', i), 'jpeg');
 end

figure (9)
plot(x, totalAccuracies(:,5), 'linewidth', 2);
title('NSC29 total accuracy over time');
xlabel('Days');
ylabel('Accuracy');
set(gca, 'fontsize', 20);
saveas(gcf, 'NSC29_totalAccuracy', 'jpeg');

figure (10)
plot(x, rightAccuracies(:,5), x, leftAccuracies(:, 5), 'linewidth', 2);
title('NSC29 right and left nose poke accuracy over time');
xlabel('Days');
ylabel('Accuracy');
legend('Right poke', 'Left poke');
set(gca, 'fontsize', 20);
saveas(gcf, 'NSC29_RLAccuracy', 'jpeg');

%% Function for breaking each into blocks and finding means

[pd1Left, pd1Right] = singleSubjectTesting(1, Trials, numberCases);
[pd3Left, pd3Right] = singleSubjectTesting(3, Trials, numberCases);

[h1, p1] = kstest2(pd1Left, pd1Right);
[h3, p3] = kstest2(pd3Left, pd3Right);

%% Make contingency table 

    maxDays = 22;
    leftTotal = 0;
    leftSuccess = 0;
    rightTotal = 0;
    rightSuccess = 0;
    totalSuccess = 0;
    n = 0;
    
    for i = 1:1: numberCases
        if i == 40

        else
        index = (i*2) + 1;
        a = strcat('T', num2str(index));
        SubjectNumber = Trials.(a).TRIALS(1,6);
        DayNumber = Trials.(a).TRIALS(1,7);
        total = length(Trials.(a).TRIALS(:,1));
        
        if DayNumber > 15 && DayNumber < 22 && SubjectNumber == 5
        for j = 1: total
            n = total + n;
            if Trials.(a).TRIALS(j,3) == -1
                leftTotal = leftTotal + 1;
                if Trials.(a).TRIALS(j,4) == -1
                    leftSuccess = leftSuccess + 1;
                    totalSuccess = totalSuccess + 1;
                end
            end
            
           if Trials.(a).TRIALS(j,3) == 1
                rightTotal = rightTotal + 1;
                if Trials.(a).TRIALS(j,4) == 1
                    rightSuccess = rightSuccess + 1;
                    totalSuccess = totalSuccess + 1;
                end
           end  
           
        end
        end
        end

    end
    
    leftFailures = leftTotal - leftSuccess;
    rightFailures = rightTotal - rightSuccess; 
    SChi = power(leftSuccess-rightSuccess, 2)/(leftSuccess+rightSuccess);
    FChi = power(leftFailures-rightFailures, 2)/(leftFailures+rightFailures);
    
    
%% Functions only 

function [massiveLeft, massiveRight] = singleSubjectTesting(subNum, Trials, numberCases)
begining = 1;
toEnd = 0;
    for i = 1: numberCases
    index = (i*2) + 1;
    
        if i == 40
        else
        b = strcat('T', num2str(index));
        SubjectNumber = Trials.(b).TRIALS(1,6);
        DayNumber = Trials.(b).TRIALS(1,7);
        
        if SubjectNumber == subNum && DayNumber > 13
            [a1, a2] = blockData(b, Trials);
            toEnd = toEnd + length(a1);
            massiveLeft(begining: toEnd, 1) = a1(:, 1);
            massiveRight(begining: toEnd, 1) = a2(:, 1);
            begining = toEnd + 1; 
        end
  
        end
    end

end


function [blockLeft, blockRight] = blockData(matFile, Trials)
    size = length(Trials.(matFile).TRIALS);
    
    leftTotal = 0;
    leftSuccess = 0;
    rightTotal = 0;
    rightSuccess = 0;
    
    index = 0;
    blockLeft = zeros(idivide(size, int16(10)), 1);
    blockRight = zeros(idivide(size, int16(10)), 1);
    
    for i = 1:size
        if Trials.(matFile).TRIALS(i,3) == -1
            leftTotal = leftTotal + 1;
            if Trials.(matFile).TRIALS(i,4) == -1
                leftSuccess = leftSuccess + 1;
            end
         end
         if Trials.(matFile).TRIALS(i,3) == 1
            rightTotal = rightTotal + 1;
            if Trials.(matFile).TRIALS(i,4) == 1
                rightSuccess = rightSuccess + 1;
            end
         end
         
         if mod(i, 10) == 0
             index = index + 1;
             blockLeft(index,1) = leftSuccess/leftTotal;
             blockRight(index, 1) = rightSuccess/rightTotal;
             leftSuccess =0; rightSuccess = 0; leftTotal = 0; rightTotal = 0; 
         end
    end
   
end


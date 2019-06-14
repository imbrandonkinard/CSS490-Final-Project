%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: /Users/beedak/Documents/MATLAB/css490/FinalProject/subset_artist_location.csv
%
% Auto-generated by MATLAB on 13-Jun-2019 13:15:49

%% Import working table for project
% Setup the Import Options
opts = delimitedTextImportOptions("NumVariables", 11);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["album", "artist", "mean_acousticness", "mean_danceability", "mean_duration_ms", "mean_liveness", "mean_tempo", "album", "artist", "GroupCount", "mean_rank"];
opts.VariableTypes = ["string", "string", "double", "double", "double", "double", "double", "string", "string", "double", "double"];
opts = setvaropts(opts, [1, 2, 8, 9], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 8, 9], "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
tbl = readtable("/working_table.csv", opts);

%% Setup the Import Options
opts = delimitedTextImportOptions("NumVariables", 6);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = [",", "<SEP>"];

% Specify column names and types
opts.VariableNames = ["id", "long", "lat", "artist", "loc", "state"];
opts.SelectedVariableNames = ["id", "long", "lat", "artist", "loc", "state"];
opts.VariableTypes = ["string", "double", "double", "string", "string", "string"];
opts = setvaropts(opts, [1, 4, 5, 6], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 4, 5, 6], "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
sub = readtable("/subset_artist_location.csv", opts);

%% Clear temporary variables
clear opts

merged = outerjoin(tbl, sub,'Keys','artist');
merged = rmmissing(merged);

% Extracting columns containing our features of interest into individual
% columns for analysis
acousticness = table2array(merged(:,3));
danceability = table2array(merged(:,4));
liveliness = table2array(merged(:,6));
duration = table2array(merged(:,5));
tempo = table2array(merged(:,7));
state = table2array(merged(:,17));

% Column in order of rank danceability duration liveliness tempo as
% indicated below
foi = [acousticness danceability liveliness duration tempo];
foi_with_state = [state acousticness danceability liveliness duration tempo];

[rows,cols] = size(merged);

% Group the merged dataset of song parameters by state
[ID, ~, index] = unique(foi_with_state(:,1));
grouped = table();
grouped.ContactID = ID;
grouped.ActivityData = cell(height(grouped), 1);
for ii = 1:length(ID)
  grouped.ActivityData{ii} = foi_with_state(index == ii, 2:end);
end

%% Preprocessing the Data

% Calculate the relevant statistics within the numerical values in the
% datasets
means = mean(foi);
stdvs = std(foi);
covs = cov(foi);

% Define X_original, nfeatures, and nsamples
X_original = foi;
[nsamples, nfeatures] = size(X_original);

X = zeros(nsamples,nfeatures);
% Mean-center/scale each feature, X is NORMALIZED & MEAN CENTERED  dataset
for i=1:nfeatures
    for j=1:nsamples
        X(j,i) = (means(:,i) - X_original(j,i))/stdvs(:,i);
    end
end
 
%% Singular Value Decomposition Function
% X is the original dataset
% Ur will be the transformed dataset
% S is covariance matrix (not normalized)
[U, S, V] = svd(X,0);
Ur = U*S;

% Number of features to use
f_to_use = nfeatures;
feature_vector = 1:f_to_use;

r = Ur;

Ur = [state Ur];

% Order Ur by date
Ur = sortrows(Ur, 1);

% Group the transformed dataset of song parameters by state
[ID, ~, index] = unique(Ur(:,1));
grouped_Ur = table();
grouped_Ur.ContactID = ID;
grouped_Ur.ActivityData = cell(height(grouped_Ur), 1);
for ii = 1:length(ID)
  grouped_Ur.ActivityData{ii} = Ur(index == ii, 2:end);
end

% %% Select random sample for original data by class
% sample_size = 500;
% 
% % Class 1
% %get the dimensions of your array   
% [s1, f1] = size(class_1_orig); 
% % add another column with a random number 
% for i=1:s1 
%     class_1_orig(i,f1+1)=rand; 
% end 
% % Randomize by sorting the matrix based on the new random column 
% class_1_orig_s1=sortrows(class_1_orig,f1+1); 
% class_1_old = [class_1_orig_s1(1:sample_size,1:f1)];
% 
% % Class 2
% %get the dimensions of your array   
% [s2, f2] = size(class_2_orig); 
% % add another column with a random number 
% for i=1:s2 
%     class_2_orig(i,f2+1)=rand; 
% end 
% % Randomize by sorting the matrix based on the new random column 
% class_2_orig_s2=sortrows(class_2_orig,f2+1); 
% class_2_old = [class_2_orig_s2(1:sample_size,1:f2)];
% 
% % Class 3
% %get the dimensions of your array   
% [s3, f3] = size(class_3_orig); 
% % add another column with a random number 
% for i=1:s3 
%     class_3_orig(i,f3+1)=rand; 
% end 
% % Randomize by sorting the matrix based on the new random column 
% class_3_orig_s3=sortrows(class_3_orig,f3+1); 
% class_3_old = [class_3_orig_s3(1:sample_size,1:f3)];
% 
% 
% %% Select random sample for transformed data by class
% 
% % Class 1
% %get the dimensions of your array   
% [s1, f1] = size(class_1_ur); 
% % add another column with a random number 
% for i=1:s1 
%     class_1_ur(i,f1+1)=rand; 
% end 
% % Randomize by sorting the matrix based on the new random column 
% class_1_ur_s1=sortrows(class_1_ur,f1+1); 
% class_1_new = [class_1_ur_s1(1:sample_size,1:f1)];
% 
% % Class 2
% %get the dimensions of your array   
% [s2, f2] = size(class_2_ur); 
% % add another column with a random number 
% for i=1:s2 
%     class_2_ur(i,f2+1)=rand; 
% end 
% % Randomize by sorting the matrix based on the new random column 
% class_2_ur_s2=sortrows(class_2_ur,f2+1); 
% class_2_new = [class_2_ur_s2(1:sample_size,1:f2)];
% 
% % Class 3
% %get the dimensions of your array   
% [s3, f3] = size(class_3_ur); 
% % add another column with a random number 
% for i=1:s3 
%     class_3_ur(i,f3+1)=rand; 
% end 
% % Randomize by sorting the matrix based on the new random column 
% class_3_ur_s3=sortrows(class_3_ur,f3+1); 
% class_3_new = [class_3_ur_s3(1:sample_size,1:f3)];
% 


%% 2D Scatter Plots of Features
% Transformed dataset
[r1, c1] = size(grouped_Ur); 

label_names = {'Acousticness (nu)', 'Danceability (nu)', ...
    'Liveness (nu)', 'Duration (ms)', 'Tempo (bpm)'};

figure;
for group_num = 1:3
    curr_class = grouped_Ur.ActivityData{group_num};
    [r2, c2] = size(curr_class);
    for y = 2:c2
        for x = 2:y - 1
            subplot(c2-1, c2-1, (c2-1) * (y - 2) + x);
            scatter(str2double(curr_class(:,x)), ...
                str2double(curr_class(:,y)), 'r', '+');
            xlabel(label_names{x-1});
            ylabel(label_names{y-1});
            hold off;
        end
    end
end
sgtitle('2D Scatter Plots of the Transformed Features in the Dataset');
%legend('1960s - 1970s','1980s - 1990s','2000s - 2010s');
% 
% % Original dataset
% [r2, c2] = size(class_1_old); 
% 
% label_names = {'Acousticness (nu)', 'Danceability (nu)', ...
%     'Liveness (nu)', 'Duration (ms)', 'Tempo (bpm)'};
% 
% figure;
% for y = 2:c2
%     for x = 2:y - 1
%         subplot(c2-1, c2-1, (c2-1) * (y - 2) + x);
%         scatter(class_1_old(:,x), class_1_old(:,y), 'r', '+');
%         hold on;
%         scatter(class_2_old(:,x), class_2_old(:,y), 'b', '*');
%         hold on;
%         scatter(class_3_old(:,x), class_3_old(:,y), 'g', '.');
%         xlabel(label_names{x-1});
%         ylabel(label_names{y-1});
%         hold off;
%     end
% end
% sgtitle('2D Scatter Plots of the Original Features in the Dataset');
% legend('1960s - 1970s','1980s - 1990s','2000s - 2010s');

% Set the folder path for ERP files
erp_folder = 'D:\Oulun\Summer Internship\N300 1\ERP(8)';
output_folder = 'RSM_Output';  % Folder to save RSM matrices and figures

% Create the output folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% List of participants
num_participants = 39;

% Define the range of channels to use (4 to 29)
selected_channels = 4:29;  % Indices of the channels to include (26 channels)

% Loop through each participant
for participant = 1:num_participants
    % Load the ERP file for the participant
    participant_file = sprintf('S%d.erp', participant);
    filepath = fullfile(erp_folder, participant_file);
    ERP = pop_loaderp('filename', participant_file, 'filepath', erp_folder);
    
    % Extract relevant dimensions
    num_conditions = ERP.nbin;         % Number of conditions (bins)
    num_electrodes = length(selected_channels);  % Number of selected electrodes
    num_timepoints = ERP.pnts;         % Number of time points
    
    % Access the ERP data (30 electrodes x 200 time points x bins)
    % Only use the selected channels
    data = ERP.bindata(selected_channels, :, :);  % Dimensions: [26 x 200 x bins]
    disp(['Participant: S' num2str(participant) ', Dimension of data: ', num2str(size(data))]);
    
    % Initialize a 3D matrix to hold the RSMs for each time point
    RSM_matrices = zeros(num_conditions, num_conditions, num_timepoints);
    
    % Create a subfolder for saving this participant's RSM figures
    participant_figures_folder = fullfile(output_folder, sprintf('RSM_Figures_S%d', participant));
    if ~exist(participant_figures_folder, 'dir')
        mkdir(participant_figures_folder);
    end
    
    % Loop through each time point to compute the RSM and plot it
    for t = 1:num_timepoints
        fprintf('Participant: S%d, Timepoint: %i \n', participant, t);
        
        % Extract data for all conditions at time t
        timepoint_data = squeeze(data(:, t, :));  % Dimensions: [26 electrodes x bins]
        
        % Compute the Spearman correlation across conditions
        temp_RSM = corr(timepoint_data, 'Type', 'Spearman');  % Correlation matrix
        
        % Store the RSM for this timepoint in the RSM_matrices array
        RSM_matrices(:, :, t) = temp_RSM;
        
        % Plot the RSM
        figure('Visible', 'off');
        imagesc(temp_RSM);  % Display the RSM
        colorbar;  % Add a colorbar
        title(['RSM for S' num2str(participant) ' at Timepoint ' num2str(t) ' (' num2str(ERP.times(t)) ' ms)']);
        xlabel('Event number');
        ylabel('Event number');
        axis square;  % Make sure the plot is square
        
        % Save the plot as a PNG image in the participant's RSM folder
        saveas(gcf, fullfile(participant_figures_folder, sprintf('RSM_Timepoint_%d.png', t)));
        
        % Close the figure to avoid too many open windows
        close;
    end
    
    % Save the RSM matrices for the participant into a MATLAB file
    mat_file_path = fullfile(output_folder, sprintf('RSM_matrices_S%d_Spearman.mat', participant));
    save(mat_file_path, 'RSM_matrices');
    
    disp(['RSM matrices and figures saved for participant S' num2str(participant)]);
end

disp('All participants processed and RSM data saved.');

function [ output_args ] = zDescription( input_args )
%--------------------------------------------------------------------------
% Description of value in vector "handles.Detect.BRSFlag"
%       0: Satisfied all BRS segment criteria
%       1: Fail R-square criteria
%       2: Change in HR is in the opposite direction of BRS
%       3: Direction of HR change is non-uniform, e.g., mix of increasing 
%          and decreasing
%      10: User manually removed BRS segment, e.g., original value is 0
%     404: Segment containing bad data
%--------------------------------------------------------------------------
% Description of value in vector "handles.Detect.Flag"
%       0: "Clean" data
%       1: Fail either BP criteria or PAT criteria
%       2: Fail both BP criteria and PAT criteria
%--------------------------------------------------------------------------
end


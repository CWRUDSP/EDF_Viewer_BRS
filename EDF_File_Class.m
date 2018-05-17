%--------------------------------------------------------------------------
% @license
% Copyright 2018 IDAC Signals Team, Case Western Reserve University 
%
% Lincensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public 
% you may not use this file except in compliance with the License.
%
% Unless otherwise separately undertaken by the Licensor, to the extent possible, 
% the Licensor offers the Licensed Material as-is and as-available, and makes no representations 
% or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other. 
% This includes, without limitation, warranties of title, merchantability, fitness for a particular purpose, 
% non-infringement, absence of latent or other defects, accuracy, or the presence or absence of errors, 
% whether or not known or discoverable. 
% Where disclaimers of warranties are not allowed in full or in part, this disclaimer may not apply to You.
%
% To the extent possible, in no event will the Licensor be liable to You on any legal theory 
% (including, without limitation, negligence) or otherwise for any direct, special, indirect, incidental, 
% consequential, punitive, exemplary, or other losses, costs, expenses, or damages arising out of 
% this Public License or use of the Licensed Material, even if the Licensor has been advised of 
% the possibility of such losses, costs, expenses, or damages. 
% Where a limitation of liability is not allowed in full or in part, this limitation may not apply to You.
%
% The disclaimer of warranties and limitation of liability provided above shall be interpreted in a manner that, 
% to the extent possible, most closely approximates an absolute disclaimer and waiver of all liability.
%
% Developed by the IDAC Signals Team at Case Western Reserve University 
% with support from the National Institute of Neurological Disorders and Stroke (NINDS) 
%     under Grant NIH/NINDS U01-NS090405 and NIH/NINDS U01-NS090408.
%              Wanchat Theeranaew
%              Farhad Kaffashi
%--------------------------------------------------------------------------
classdef EDF_File_Class %Improved Lazy version
    %Encapsulate file read for EDF_FileInfo  
    % Version 1.13 (2016/04/21)
    % Wanchat Theeranaew
    
    properties
       FileName
       FileInfo
    end
    
    methods
        function obj = EDF_File_Class(FileName)
            if nargin == 1
                Fid = fopen(FileName);
                
                if Fid ~= -1
                    obj.FileName = FileName;
                    obj.FileInfo = EDF_FileInfo(FileName);
                    fclose(Fid);
                else
                    error(['Cannot open [' FileName '].']);
                end;
            else
                error('Need to specify EDF file to create this object.');
            end            
        end
        
        
        function data = FileRead(obj,DataStart,DataLength,chList,Segment)       
            data = obj.FileReadDigital(DataStart,DataLength,chList,Segment);
            chList = unique(chList);
            
            for i = 1:length(chList)
               curChID = chList(i);
               Multiplier = (obj.FileInfo.ChInfo.PhysicalMaximum(curChID) - obj.FileInfo.ChInfo.PhysicalMinimum(curChID)) ./ ...
                            (obj.FileInfo.ChInfo.DigitalMaximum(curChID) - obj.FileInfo.ChInfo.DigitalMinimum(curChID)); 
                         
               data{chList(i)} = Multiplier * double(data{chList(i)} - obj.FileInfo.ChInfo.DigitalMinimum(curChID)) + ...
                  obj.FileInfo.ChInfo.PhysicalMinimum(curChID);
            end;
        end  
        
        
        function data = FileReadDigital(obj,DataStart,DataLength,chList,Segment)       
            data = [];
            %--------------------------------------------------------------------------
            Fid = fopen(obj.FileName,'r');
   
            %Block shift depend on the current segment of data
            Temp = fix([0 cumsum(obj.FileInfo.TotalTime)] / obj.FileInfo.DurationOfEachRecord);

            %EDF file reader
            startBlock = 1 + fix(DataStart / obj.FileInfo.DurationOfEachRecord) + Temp(Segment);
            endblock = 1 + fix((DataStart + DataLength) / obj.FileInfo.DurationOfEachRecord) + Temp(Segment);

            CummulativeSampleTable = cumsum(obj.FileInfo.ChInfo.NumberOfSampleInEachRecord);
            CummulativeSampleTable = [0; CummulativeSampleTable(1:end)];
            SkipBytes = obj.FileInfo.HeaderSizeInByte + 2*((startBlock - 1) * CummulativeSampleTable(end));
           
            for i = 1:length(chList)
                fseek(Fid,SkipBytes + 2*CummulativeSampleTable(chList(i)),'bof');
                
                numberOfDataPoint = (endblock - startBlock + 1) * obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i));

                % Prepare information to read chunk of data
                Temp = 2*(CummulativeSampleTable(end) - obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i))); % Skip data from other channel for each recording

                % Actually start to read the data
                data{chList(i)} = fread(Fid,[1 numberOfDataPoint], [num2str(obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i))) '*int16=>double'], Temp); 

               %Extract the actual data be discarding unwanted data
               idx1 = (DataStart - (startBlock-1)*obj.FileInfo.DurationOfEachRecord)/obj.FileInfo.DurationOfEachRecord*obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i)) + 1;
               idx1 = max(fix(idx1),1);
               idx2 = idx1 + obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i))/obj.FileInfo.DurationOfEachRecord*DataLength - 1;
            
               idx2 = min(fix(idx2),length(data{chList(i)}));

               data{chList(i)} = data{chList(i)}(idx1:idx2);              
            end;
            
            fclose(Fid);
            %--------------------------------------------------------------------------            
        end        
        
        % Get basic information from FileInfo
        function output = getStartDate(obj)
            output = obj.FileInfo.StartDate;
        end

        function output = getStartTime(obj)
            output = obj.FileInfo.StartTime;
        end        
        
        function output = getSegmentStartTime(obj)
            output = obj.FileInfo.SegmentStartTime;
        end   
 
        function output = getTotalTime(obj)
            output = obj.FileInfo.TotalTime;
        end   
                
        function output = getNumberOfSignals(obj)
            output = obj.FileInfo.NumberOfSignals;
        end    
        
        function output = getSamplingRate(obj)
            output = obj.FileInfo.ChInfo.NumberOfSampleInEachRecord / obj.FileInfo.DurationOfEachRecord;
        end     
        
        function output = getChMap(obj)
            output = obj.FileInfo.ChInfo.ChMap;
        end  
        
        function output = getPhysicalUnit(obj)
            output = obj.FileInfo.ChInfo.PhysicalDimension;
        end  
    
        function output = getPhysicalMaximum(obj)
            output = obj.FileInfo.ChInfo.PhysicalMaximum;
        end      
    
        function output = getPhysicalMinimum(obj)
            output = obj.FileInfo.ChInfo.PhysicalMinimum;
        end      

        function output = getHeaderBytes(obj)
            output = obj.FileInfo.HeaderBytes;
        end  
        
        function output = getNumberOfSampleInEachRecord(obj)
            output = obj.FileInfo.ChInfo.NumberOfSampleInEachRecord;
        end    
        
        function output = getDurationOfEachRecord(obj)
            output = obj.FileInfo.DurationOfEachRecord;
        end  
        
        function output = getPatientIdentification(obj)
            output = obj.FileInfo.PatientIdentification;
        end     
 
        function output = getNumberOfSegment(obj)
            output = obj.FileInfo.NumberOfSegment;
        end           

        function output = getAnnotation(obj)
            output = obj.FileInfo.Annotation;
        end      
    end
end
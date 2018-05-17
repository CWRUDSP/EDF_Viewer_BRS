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
function [ FileInfo ] = EDF_FileInfo(FileName)
   %--------------------------------------------------------------------------
   % Input
   % FileName : '*.EDF' file name
   %--------------------------------------------------------------------------
   %--------------------------------------------------------------------------
   % Version 0.611v
   %  - Can read data for both EDF and EDF+
   %  - For EDF, annotation MUST store in separate text file with Farhad's
   %    format.
   %        - Annotation file MUST has the same name as EDF file but has txt 
   %          as a file extension. 
   %        - For each line in annotation file, there is one event in the
   %          following format "HH:MM:SS.FFF [Annotation text]".
   %
   %  - All text information are stored in cell array format.
   %  - Time storage of annotation is in seconds (as cell array)
   %  - Fix Annotation reader
   %--------------------------------------------------------------------------
   % Version 1.0
   % Wanchat Theeranaew
   %--------------------------------------------------------------------------

   fid=fopen(FileName,'r');
   %--------------------------------------------------------------------------
   % Start with reading global information
   %--------------------------------------------------------------------------
   % Version: 8 ascii : version of this data format (0) 
   FileInfo.Version = fread(fid,[1 8],'*char');

   % 80 ascii : local patient identification (mind item 3 of the additional EDF+ specs)
   FileInfo.PatientIdentification = fread(fid,[1 80],'*char');

   % 80 ascii : local recording identification (mind item 4 of the additional EDF+ specs)
   FileInfo.LocalRecordingIdentification = fread(fid,[1 80],'*char');

   % 8 ascii : startdate of recording (dd.mm.yy) (mind item 2 of the additional EDF+ specs)
   FileInfo.StartDate = fread(fid,[1 8],'*char');
   FileInfo.StartDate([3 6]) = '//';
   %fprintf('start date: %s\n',FileInfo.StartDate)

   % 8 ascii : starttime of recording (hh.mm.ss) 
   FileInfo.StartTime = fread(fid,[1 8],'*char');
   FileInfo.StartTime([3 6]) = '::';
   %fprintf('start time: %s\n',FileInfo.StartTime)

   % 8 ascii : number of bytes in header record
   FileInfo.HeaderSizeInByte = str2num(fread(fid,[1 8],'*char'));

   % 44 ascii : reserved
   FileInfo.Reserved = fread(fid,[1 44],'*char');

   % 8 ascii : number of data records (-1 if unknown, obey item 10 of the additional EDF+ specs)
   FileInfo.NumberOfDataRecords = str2num(fread(fid,[1 8],'*char'));

   % 8 ascii : duration of a data record, in seconds
   FileInfo.DurationOfEachRecord = str2num(fread(fid,[1 8],'*char'));
   %duration = FileInfo.DurationOfEachRecord
   % 4 ascii : number of signals (ns) in data record 
   FileInfo.NumberOfSignals = str2num(fread(fid,[1 4],'*char'));
   %--------------------------------------------------------------------------
   %--------------------------------------------------------------------------

   %--------------------------------------------------------------------------
   % Record Information of Individual Signal Into FileInfo
   % ***Use Farhad's method to read channel data (No loop)
   %--------------------------------------------------------------------------
   ns = FileInfo.NumberOfSignals;

   % ns * 16 ascii : ns * label (e.g. EEG Fpz-Cz or Body temp) (mind item 9 of the additional EDF+ specs)
   Temp = fread(fid,[16 ns],'*char')';

   % ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode) 
   Temp1 = fread(fid,[80 ns],'*char')';

   % ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC) 
   Temp2 = fread(fid,[8 ns],'*char')';

   % ns * 8 ascii : ns * physical minimum (e.g. -500 or 34) 
   FileInfo.ChInfo.PhysicalMinimum = str2num(fread(fid,[8 ns],'*char')');

   % ns * 8 ascii : ns * physical maximum (e.g. 500 or 40) 
   FileInfo.ChInfo.PhysicalMaximum = str2num(fread(fid,[8 ns],'*char')');

   % ns * 8 ascii : ns * digital minimum (e.g. -2048)   
   FileInfo.ChInfo.DigitalMinimum = str2num(fread(fid,[8 ns],'*char')');

   % ns * 8 ascii : ns * digital maximum (e.g. 2047) 
   FileInfo.ChInfo.DigitalMaximum = str2num(fread(fid,[8 ns],'*char')');

   % ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz) 
   Temp3 = fread(fid,[80 ns],'*char')';

   % ns * 8 ascii : ns * nr of samples in each data record 
   FileInfo.ChInfo.NumberOfSampleInEachRecord = str2num(fread(fid,[8 ns],'*char')');
      
   % ns * 32 ascii : ns * reserved
   Temp4 = fread(fid,[32 ns],'*char')';

   fclose(fid);

   % Store ChInfo and as cell array
   FileInfo.ChInfo.ChMap = {};
   FileInfo.ChInfo.PhysicalDimension = [];
   for i = 1:FileInfo.NumberOfSignals 
      FileInfo.ChInfo.ChMap{i} = strtrim(Temp(i,:));
      FileInfo.ChInfo.TransducerType{i} = strtrim(Temp1(i,:));
      FileInfo.ChInfo.PhysicalDimension{i} = strtrim(Temp2(i,:));
      FileInfo.ChInfo.Prefiltering{i} = strtrim(Temp3(i,:));
      FileInfo.ChInfo.Reserved{i} = strtrim(Temp4(i,:));
   end;

   clear Temp Temp1 Temp2 Temp3 Temp4; %Free memory ***Must do***
   %--------------------------------------------------------------------------
   %--------------------------------------------------------------------------
   FileInfo.Annotation.Time = [];
   FileInfo.Annotation.Text = [];
   %--------------------------------------------------------------------------
   % Record Annotation (Might need to move to other place)
   %--------------------------------------------------------------------------
   if strcmp(FileInfo.Reserved(1:4),'EDF+')
      disp(['File format: ' FileInfo.Reserved(1:5)]);
      
      %Find the channel for annotation
      AnnChID = -1;

      for i=1:FileInfo.NumberOfSignals
         if strcmpi(strtrim(FileInfo.ChInfo.ChMap{i}),'EDF Annotations')
            AnnChID = i;
            break
         end
      end
      
      if(AnnChID == -1)
         warning('EDF+ does not contain annotation.');
         FileInfo.Annotation = [];
      else
         % open file
         fid = fopen(FileName,'r');
          
         % prepare to seek to first annotation string.
         bytes_per_sample = 2;
         header_bytes_count = FileInfo.HeaderSizeInByte;
         block_annotation_samples_count = FileInfo.ChInfo.NumberOfSampleInEachRecord(AnnChID);     
         block_bytes_before_annotation_count = bytes_per_sample * sum(FileInfo.ChInfo.NumberOfSampleInEachRecord(1:AnnChID-1));

         % go to first annotation
         bytes_beg = 1 + header_bytes_count + block_bytes_before_annotation_count;
         fseek(fid, bytes_beg, 'bof');

         % prepare to read all annotations data
         blocks_count = FileInfo.NumberOfDataRecords;
         block_samples_count = sum(FileInfo.ChInfo.NumberOfSampleInEachRecord);
         skip_bytes = bytes_per_sample * (block_samples_count - block_annotation_samples_count);

         % empty_annotation = char(['20', zeros(1,2*block_annotation_samples_count - 2)]);
         blocks_count = FileInfo.NumberOfDataRecords;
         block_bytes_shape = [blocks_count-1, bytes_per_sample * block_annotation_samples_count];
         precision = [ num2str(bytes_per_sample * FileInfo.ChInfo.NumberOfSampleInEachRecord(AnnChID)), '*char=>char'];
         skip_bytes = (block_samples_count - block_annotation_samples_count) * bytes_per_sample;

         % read annotation blocks
         [block_bytes, bytes_read_count] = fread(fid, [ 1, prod(block_bytes_shape)] , precision, skip_bytes);

         %reshape block annotations
         block_bytes = reshape(block_bytes, 2*block_annotation_samples_count, []).';
         
         % block times ( which the edf+ file must have), 
         % as quickly as possible. not if we have to re-read a block if there
         % is more than just the block's time-start information.
         tal_start_chars = '-+';
         blocks.time_starts = cell(blocks_count-1,1);
         blocks.has_tal = repmat(false,blocks_count-1,1);
         for i = 1:blocks_count-1
            %parse block time.
            %Modified by Wanchat 2015/06/29(using strfind instead of while loop)
            j = strfind(block_bytes(i,:),char([20 20]));
            if(isempty(j))
               j = 2*block_annotation_samples_count;
            end;

            blocks.time_starts{i} = block_bytes(i,1:j-1);
            blocks.time_starts_numerical(i) = str2num(blocks.time_starts{i}); %Add by Wanchat for EDF+D 2015/06/29       
            blocks.has_tal(i) = any(block_bytes(i,j+2) == tal_start_chars);         
            if mod(i,1000) ==0, fprintf('blocks.time_start{%i}: %s\n', i-1, blocks.time_starts{i}), end;         
         end

         blocks.tals = {};
         blocks.tals_count = 0;
         blocks.tals_indeces = {};
         for i = 1:blocks_count-1
            if blocks.has_tal(i)
               %add another tal
               blocks.tals_count = blocks.tals_count + 1;

               %store index
               blocks.tals_indeces{blocks.tals_count} = i;
               ann_str = block_bytes(i,numel(blocks.time_starts{i})+3:end);
               blocks.tals{blocks.tals_count} = parse_edf_plus_block_tal(ann_str,false);
            end
         end


         annotation.Time=[];
         annotation.Duration=[];
         annotation.Text=[];
         ann_index = 1;
         if strcmpi(FileInfo.Reserved(1:5),'edf+d') || strcmpi(FileInfo.Reserved(1:5),'edf+c')

            onset_time_mod = 24*3600;
            for i=1:blocks.tals_count
                block_index = blocks.tals_indeces{i};
               
                %    jim.todo: make sure time incorporates file and date-time rollover
                %    xparse onset time
                start_date = FileInfo.StartTime;
                [~, ~, ~, H, MN, S] = datevec(FileInfo.StartTime);

                file_onset_time = H*3600 + MN*60 + S;
                block_plus_minus_str = blocks.time_starts{i};
                block_plus_minus_char = block_plus_minus_str(1);
                block_plus_minus_str = block_plus_minus_str(2:end);
                block_onset_time = sum([1,-1] .* (block_plus_minus_char == '+-') * str2double(block_plus_minus_str));
                for j = 1:numel(blocks.tals{i})
                    annotation_onset_char = blocks.tals{i}{j}.onset(1);

                    annotation_onset_str = '';
                    if strcmpi(annotation_onset_char,'+')
                        annotation_onset_str = blocks.tals{i}{j}.onset(2:end);
                    elseif strcmpi(annotation_onset_char,'-')
                        annotation_onset_str = blocks.tals{i}{j}.onset;
                    else
                        warning('ughh needs to be +-')
                    end

                    annotation_onset_time=str2double(annotation_onset_str);
                    file_onset_time = annotation_onset_time + block_onset_time;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %TODO: REVIEW: Does this need time file start added also?
                    %file_onset_time = file_onset_time + file_onset_time;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    file_onset_time = mod(file_onset_time, onset_time_mod);
                    annotation.Time{ann_index} = file_onset_time;
                    annotation.Duration{ann_index} = str2double(blocks.tals{i}{j}.duration);
                    %blocks.tals{i}{j}.annotations
                    annotation.Text{ann_index} = cellString2Text(blocks.tals{i}{j}.annotations);                  
                    ann_index = ann_index+1;
                end                    
            end
         end

         % close file
         fclose(fid);
         
         FileInfo.Annotation = annotation;
      end
   else
      % Farhad's EDF Annotation format 
      % ***CANNOT use with other annotation formats***
      FileName([(end-2):end]) = 'txt';
      fid=fopen(FileName,'r');
      if(fid == -1)
%          warning('Annotation file is not aviable.');
%          FileInfo.Annotation = [];
      else
         Temp = fgetl(fid);
         i = 1;
         while ischar(Temp)
            try
               date_str = Temp(1:12);
               [Y, M, D, H, MN, S] = datevec(Temp(1:12));
               FileInfo.Annotation.Time{i} = H*3600+MN*60+S;
               FileInfo.Annotation.Text{i} = Temp(14:end);
               i = i + 1;
            catch err %Different Annotation format: skip that line
            end
            Temp = fgetl(fid);
         end
         fclose(fid);
      end
   end;
   %--------------------------------------------------------------------------
   %--------------------------------------------------------------------------

   if strcmp(FileInfo.Reserved(1:5),'EDF+D')
% %*****************************TEST PURPOSE ONLY****************************      
% %Force all EDF+D to be incontiguous since we DO NOT have actual EDF+D
% X = 0.5 + 0.25*(rand-0.5);
% Y = ceil(X * FileInfo.NumberOfDataRecords);     
% blocks.time_starts_numerical(Y:end) = blocks.time_starts_numerical(Y:end) + 2*3600; %Add 2 hour
% %*****************************TEST PURPOSE ONLY****************************      
      %Add by Wanchat for EDF+D 2015/06/29 (Incomplete!!!!)
      Temp = diff(blocks.time_starts_numerical);
      Temp1 = sum(Temp ~= FileInfo.DurationOfEachRecord);
      if( Temp1 == 0) %check for incontiguous block!!!
         FileInfo.NumberOfSegment = 1;
         FileInfo.TotalTime = FileInfo.NumberOfDataRecords * FileInfo.DurationOfEachRecord;
         FileInfo.SegmentStartTime = 0;
      else % There are incontiguous segments.
         %The code is complete but need to actually check with data!!!!!*******************************************
         Temp1 = find(Temp ~= FileInfo.DurationOfEachRecord);
         Temp = [1 (Temp1+1) FileInfo.NumberOfDataRecords+1];

         FileStart = datenum([FileInfo.StartDate '-' FileInfo.StartTime],'dd/mm/yyyy-HH:MM:SS');

         FileInfo.NumberOfSegment = length(Temp1) + 1;
         for i=1:FileInfo.NumberOfSegment
            Temp2 = FileStart + blocks.time_starts_numerical(Temp(i))/86400;
            Temp2 = datestr(Temp2,'dd/mm/yyyy-HH:MM:SS')
            FileInfo.SegmentStartTime(i) = blocks.time_starts_numerical(Temp(i));
            FileInfo.TotalTime(i) = (Temp(i+1) - Temp(i))*FileInfo.DurationOfEachRecord;         
         end;
      end;
   else
      FileInfo.NumberOfSegment = 1;
      FileInfo.TotalTime = FileInfo.NumberOfDataRecords * FileInfo.DurationOfEachRecord;
      FileInfo.SegmentStartTime = 0;
   end;
   
function text = cellString2Text(cellString)
   len = length(cellString);
   text = '';
   
   for i = 1:len
      text = [text ', ' cellString{i}];
   end;
   
   if(~isempty(text))
      text = text(3:end);
   end;

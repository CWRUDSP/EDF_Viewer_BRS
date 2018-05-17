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
%--------------------------------------------------------------------------
function [FolderList, FileList] = findFile(MainPath,SubPath,Extension)
   % Use appropriate seperator for directory
   if ispc
       MainPath = [MainPath '\'];
   else
       MainPath = [MainPath '/'];
   end
   
   Temp = dir([MainPath SubPath]);
   Extension = lower(Extension); % Use lower case
   
   FolderList = [];
   FileList = [];
   
   for i = 1:length(Temp)
      Temp1 = Temp(i).name;
      
      if((Temp(i).isdir == 1) && (sum(strfind(Temp1,'.')) == 0))     
         if ispc
            Temp2 = [SubPath '\' Temp1];
         else
            Temp2 = [SubPath '/' Temp1];
         end;     
         [Temp1, Temp2] = findFile(MainPath,Temp2,Extension);
         FolderList = [FolderList Temp1];
         FileList = [FileList Temp2];
      elseif(length(Temp1) > 4)&&(strcmp(lower(Temp1(end-3:end)),['.' Extension]))
         Temp2 = [];
         Temp2{1} = SubPath;
         FolderList = [FolderList Temp2];
         Temp2{1} = Temp1;
         FileList = [FileList Temp2];
      end;
   end;   
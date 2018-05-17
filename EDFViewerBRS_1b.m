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
% Where disclaimers of warranties are not allowed n full or in part, this disclaimer may not apply to You.
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
function varargout = EDFViewerBRS_1b(varargin)
% EDFVIEWERBRS_1B MATLAB code for EDFViewerBRS_1b.fig
%      EDFVIEWERBRS_1B, by itself, creates a new EDFVIEWERBRS_1B or raises the existing
%      singleton*.
%
%      H = EDFVIEWERBRS_1B returns the handle to a new EDFVIEWERBRS_1B or the handle to
%      the existing singleton*.
%
%      EDFVIEWERBRS_1B('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDFVIEWERBRS_1B.M with the given input arguments.
%
%      EDFVIEWERBRS_1B('Property','Value',...) creates a new EDFVIEWERBRS_1B or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EDFViewerBRS_1b_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EDFViewerBRS_1b_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EDFViewerBRS_1b

% Last Modified by GUIDE v2.5 27-Mar-2018 14:06:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EDFViewerBRS_1b_OpeningFcn, ...
                   'gui_OutputFcn',  @EDFViewerBRS_1b_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EDFViewerBRS_1b is made visible.
function EDFViewerBRS_1b_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EDFViewerBRS_1b (see VARARGIN)

   % Choose default command line output for EDFViewerBRS_1b
   handles.output = hObject;

   handles.Files.Folder = [];
   handles.Files.ResultFolder = pwd;
   handles.Files.FolderList = {};
   handles.Files.FileList = {};
   handles.Files.CurFile = 0;
   handles.Files.Extension = 'EDF';
   handles.Files.EDFObj = [];
   handles.Files.SelSegment = 1;
   if ispc
      handles.seperater = '\';
   else
      handles.seperater = '/';
   end
   
   handles = UpdateDisplaySetting(handles);
   handles.Display.StartTime = 0;
   
   handles.Display.SelectedCh = [];
   
   %Channel name for auto-detection
   handles.List{1} = {'ekg','ecg'}; 
   handles.List{2} = {'bp','dc10'};
   
   handles.ExpFolder = [];
   
   %Detection/Computation parameters
   handles.Parameters = GetDefaultComputationParameter;
   UpdateDisplayParameter(handles);
   
   % Update handles structure
   guidata(hObject, handles);

% UIWAIT makes EDFViewerBRS_1b wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EDFViewerBRS_1b_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ListEDFFile.
function ListEDFFile_Callback(hObject, eventdata, handles)
   sel = get(hObject,'value');
   N = length(handles.Files.FolderList);
   
   if(sel < 1) || (sel > N)
      handles.Files.CurFile = N;
   else
      handles.Files.CurFile = sel;
      %Extract information
      curEDF = [handles.Files.FolderList{handles.Files.CurFile} handles.seperater handles.Files.FileList{handles.Files.CurFile}];
      curEDF = [handles.Files.Folder curEDF];
      handles.Files.EDFObj = EDF_File_Class(curEDF);
      %[FileInfo ChInfo] = EdfInfo(curEDF);
      handles.Display.StartTime = 0;
      
      genComment(handles);
      
      chMaps = handles.Files.EDFObj.getChMap;
      for i = 1:length(chMaps)
         chMaps{i} = lower(chMaps{i});
      end;
      
      %Auto-detect channels here!!!
      handles.Display.SelectedCh = [];
      for i = 1:length(handles.List)
         handles.Display.SelectedCh(i,:) = [0 0];
         ch_idx = [];
         for j = 1:length(handles.List{i})
            for k = 1:length(chMaps)
               Temp = strfind(chMaps{k},handles.List{i}{j});
               if(~isempty(Temp))
                  ch_idx = [ch_idx, k];
               end;
            end;
            ch_idx = unique(ch_idx);
         end;
         ch_idx = sort(ch_idx);
         
         if(~isempty(ch_idx))
            handles.Display.SelectedCh(i,1) = ch_idx(1);
         end;
      end;
      
      chMaps = handles.Files.EDFObj.getChMap;
      set(handles.popupmenuEKG,'string',['-' chMaps],'value',handles.Display.SelectedCh(1,1)+1)
      set(handles.popupmenuEKG2,'string',['-' chMaps],'value',1)
      set(handles.popupmenuAbd,'string',['-' chMaps],'value',handles.Display.SelectedCh(2,1)+1)
      
      %--------------------------------------------------------------------
      %Reset all detections and computations
      handles.Detect.R = [];     
      handles.Detect.BPTime = []; %Systolic Time
      handles.Detect.BPSys = []; %Systolic Value
      handles.Detect.BPDias = []; %Systolic Value
      handles.Detect.BPAvg = []; %Average Value
      handles.Detect.Flag = [];
      
      handles.Detect.BRSidx = [];
      handles.Detect.BRSFlag = [];
      handles.Detect.Slope = [];
      handles.Detect.Rsquare = [];
      handles.Detect.SpectralBRS = [];
      
      handles.Compute.BRS = [];
      
      set(handles.ListBRS,'string','-','value',1)
      set(handles.ListSpecBRS,'string','-','value',1)
      
      axes(handles.axesBRS);
      cla;
      %--------------------------------------------------------------------
   end;
   
   handles = UpdateDisplaySetting(handles);
   handles.Parameters = GetDefaultComputationParameter;   
   handles = LoadComputation(handles);
   handles.Display.StartTime = 0;
   handles = MoveToLocation(handles);
   handles = FileRead(handles);   
   UpdatePlot(handles);
   UpdateDisplayParameter(handles);
   guidata(hObject, handles);

   
function UpdatePlot(handles)
   PlotStart = handles.Display.StartTime;
   PlotEnd = handles.Display.StartTime + handles.Display.Window;
   Comment = handles.Files.EDFObj.getAnnotation;
   Y = cell2mat(Comment.Time);
   idx = find(Y-PlotStart-handles.Display.Window/2 >= 0,1,'first');
   if(~isempty(idx))
      set(handles.listboxComment,'value',idx)
   end;
   
   if(isempty(handles.Display.SelectedCh))
      return;
   end;

   FsEDF = handles.Files.EDFObj.getSamplingRate;
   for i = 1:size(handles.Display.SelectedCh,1)
      handles.Display.SelectedCh(i,1);
      if (handles.Display.SelectedCh(i,1) ~= 0)
         Fs(i) = FsEDF(handles.Display.SelectedCh(i,1));
      else
         Fs(i) = 0;
      end;
   end;
         
   %-----------------------------------------------------------------------
   % Color background
   RArea = [];
   BPArea = [];
   SArea = [];
   bgColor = [1 1 0.8; 1 0.9 0.9];
   bgColor2 = [0.9 1 0.5; 0.7 0.7 0.7];
   plotMult = [1 0.9];
   if(~isempty(handles.Detect.BRSidx))     
      idxRaw = handles.Detect.BRSidx;
      idxBRS = (handles.Detect.R(idxRaw + handles.Parameters.Delay + handles.Parameters.SegLen) <= PlotStart) + (handles.Detect.BPTime(idxRaw) >= PlotEnd);  
      idxBRS = idxBRS + ((handles.Detect.BRSFlag ~= 0) .* (handles.Detect.BRSFlag ~= 10));
      idxBRS = find(idxBRS == 0);
      idxRaw = idxRaw(idxBRS);
      
      for i = 1:length(idxRaw)               
         RArea{i} = [handles.Detect.R(idxRaw(i)+handles.Parameters.Delay) handles.Detect.R(idxRaw(i)+handles.Parameters.Delay+handles.Parameters.SegLen+1)];
         BPArea{i} = [handles.Detect.BPTime(idxRaw(i)) handles.Detect.BPTime(idxRaw(i)+handles.Parameters.SegLen)];
         SponColor(i) = (handles.Detect.BRSFlag(idxBRS(i)) ~= 0) + 1;
      end;
      
   end;   
   if(~isempty(handles.Detect.SpectralBRS))
      idxBRS = (handles.Detect.SpectralBRS(:,2) <= PlotStart) + (handles.Detect.SpectralBRS(:,1) >= PlotEnd);        
      idxBRS = find(idxBRS == 0);      
      
      for i = 1:length(idxBRS)      
         SArea{i} = [handles.Detect.SpectralBRS(idxBRS(i),1) handles.Detect.SpectralBRS(idxBRS(i),2)];
         SpecColor(i) = (handles.Detect.SpectralBRS(idxBRS(i),end) ~= 0) + 1;
         SpecColorMult(i) = plotMult(mod(idxBRS(i),2)+1);
      end;
   end;   
   %-----------------------------------------------------------------------
   
   axes(handles.axes1)
   cla;
   Data = handles.Data{1};
   rTime = [];
   hold on;
   if(~isempty(Data))
      Time = handles.Display.StartTime + ([1:1:length(Data)] - 1)/Fs(1);   
      wo = 60/(Fs(1)/2);  bw = wo/35;
      [B,A] = iirnotch(wo,bw); % design the notch filter for the given sampling rate
      Temp = filter(B,A,Data); 
      maxPlot = max(Temp);
      minPlot = min(Temp);
      maxPlot = maxPlot + (maxPlot - minPlot)*0.05;
      minPlot = minPlot - (maxPlot - minPlot)*0.05;
      if(minPlot == maxPlot)
         maxPlot = maxPlot + 1;
         minPlot = minPlot - 1;
      end;
          
      if(~isempty(SArea))    
         for i = 1:length(SArea)
            rectangle('Position',[SArea{i}(1) minPlot diff(SArea{i}) (maxPlot-minPlot)],...
               'FaceColor',SpecColorMult(i)*bgColor2(SpecColor(i),:),'EdgeColor','none');
         end;
      end;
      if(~isempty(RArea))    
         for i = 1:length(RArea)      
            rectangle('Position',[RArea{i}(1) minPlot+0.05*(maxPlot-minPlot) diff(RArea{i}) 0.9*(maxPlot-minPlot)],...
               'FaceColor',bgColor(SponColor(i),:),'EdgeColor','none');  
         end;
      end;
      
      %Plot auto-detection
      idx1 = find(handles.Detect.R > Time(1),1,'first');
      idx2 = find(handles.Detect.R < Time(end),1,'last');
      idx2 = min(idx2,length(handles.Detect.Flag));
      Temp1 = handles.Detect.R(idx1:idx2);
      Temp2 = handles.Detect.Flag(idx1:idx2);
      idx = find((Temp2 > 0).*(Temp2 < 100));      
      line([Temp1(idx) Temp1(idx)]',[Temp1(idx)*0+minPlot Temp1(idx)*0+maxPlot]','Color','r')
      idx = find((Temp2 == 0)+(Temp2 >= 100));
      line([Temp1(idx) Temp1(idx)]',[Temp1(idx)*0+minPlot Temp1(idx)*0+maxPlot]','Color','g')     
      
      %Plot Signal on top of detection
      plot(Time,Temp,'Color','b');
      xlim([Time(1) Time(end)]);
      ylim([minPlot-0.01 maxPlot]);         
   end;
   hold off;
   
   axes(handles.axes3)
   cla;
   Data = handles.Data{2};
   hold on;
   if(~isempty(Data))
      Time = handles.Display.StartTime + ([1:1:length(Data)] - 1)/Fs(2);
      maxPlot = max(Data);
      minPlot = min(Data);
      maxPlot = maxPlot + (maxPlot - minPlot)*0.05;
      minPlot = minPlot - (maxPlot - minPlot)*0.05;  
      if(minPlot == maxPlot)
         maxPlot = maxPlot + 1;
         minPlot = minPlot - 1;
      end;
      
      if(~isempty(SArea))    
         for i = 1:length(SArea)   
            rectangle('Position',[SArea{i}(1) minPlot diff(SArea{i}) (maxPlot-minPlot)],...
               'FaceColor',SpecColorMult(i)*bgColor2(SpecColor(i),:),'EdgeColor','none');
         end;
      end;
      if(~isempty(BPArea))    
         for i = 1:length(BPArea)
            rectangle('Position',[BPArea{i}(1) minPlot+0.05*(maxPlot-minPlot) diff(BPArea{i}) 0.9*(maxPlot-minPlot)],...
               'FaceColor',bgColor(SponColor(i),:),'EdgeColor','none');       
         end;
      end;
      
      if(~isempty(handles.Detect.BPTime))      
         %Plot verified auto-detection
         idx1 = find(handles.Detect.BPTime(:,1) > Time(1),1,'first');
         idx2 = find(handles.Detect.BPTime(:,1) < Time(end),1,'last');
         Temp1 = handles.Detect.BPTime(idx1:idx2);
         Temp2 = handles.Detect.Flag(idx1:idx2);            
         %Systolic
         idx = find((Temp2 > 0).*(Temp2 < 100)); 
         line([Temp1(idx) Temp1(idx)]',[Temp1(idx)*0+minPlot Temp1(idx)*0+maxPlot]','Color','r')
         idx = find((Temp2 == 0)+(Temp2 >= 100));
         line([Temp1(idx) Temp1(idx)]',[Temp1(idx)*0+minPlot Temp1(idx)*0+maxPlot]','Color','g')           
      end; 
            
      %Plot data
      plot(Time,Data);
      
      xlim([Time(1) Time(end)]);
      ylim([minPlot maxPlot]);
   end;
   hold off;
   grid on;
   
   set(handles.axes1,'xTick',[]);
   %set(handles.axes3,'xTick',[]);
   SetAbsTime(handles);
    
   
function handles = UpdateDisplaySetting(handles)
   Temp = get(handles.PopupDispWindow,'string');
   Sel = get(handles.PopupDispWindow,'value');
   Temp = Temp{Sel}(1:end-3);
   handles.Display.Window = str2num(Temp);
   handles.Display.Grid = get(handles.CheckboxGrid,'value');
   handles.Display.ActualTime = get(handles.CheckboxActualTime,'value');
   handles.Display.RawData = get(handles.CheckboxRawData,'value');   

   
% --- Executes on selection change in PopupDispWindow.
function PopupDispWindow_Callback(hObject, eventdata, handles)
   handles = UpdateDisplaySetting(handles);
   handles = FileRead(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);

   
% --- Executes on button press in CheckboxGrid.
function CheckboxGrid_Callback(hObject, eventdata, handles)
   handles = UpdateDisplaySetting(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);

   
% --- Executes on button press in CheckboxActualTime.
function CheckboxActualTime_Callback(hObject, eventdata, handles)
   handles = UpdateDisplaySetting(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);

   
% --- Executes on button press in CheckboxRawData.
function CheckboxRawData_Callback(hObject, eventdata, handles)
   handles = UpdateDisplaySetting(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);

   
function  SetAbsTime(handles)
   Temp = get(gca,'xTick');
   Label=[];

   if handles.Display.ActualTime
       Time = datenum([handles.Files.EDFObj.getStartDate '--' handles.Files.EDFObj.getStartTime],'dd/mm/yy--HH:MM:SS');
   else
       Time = 0;
   end
   Label = datestr(Temp/86400+Time,'HH:MM:SS');

   set(gca,'xTickLabel',Label);   
   
   
function handles = FileRead(handles)
    Temp = handles.Files.EDFObj.getSegmentStartTime;
    DataStart = handles.Display.StartTime;
    DataLength = handles.Display.Window;
    
    % Additional code to not extract data from non-display channel (Speed up unless user want to display all channels)
    Temp = handles.Display.SelectedCh;
    Temp1 = unique(Temp); %Get distinct channel  
    Temp = find(Temp1); 
    Temp1 = Temp1(Temp); %Remove 0 from index

    DataOrg = handles.Files.EDFObj.FileRead(DataStart,DataLength,Temp1,handles.Files.SelSegment);

    SelectedCh = handles.Display.SelectedCh;
    handles.Data={};

    % construct the selected referential and differential channels
    for i=1:size(SelectedCh,1)
        if SelectedCh(i,1) == 0
            handles.Data{i}=[];        
        elseif SelectedCh(i,2) == 0
            % referential
            handles.Data{i}=DataOrg{SelectedCh(i,1)};
        else
           % differential
           if(length(DataOrg{SelectedCh(i,1)}) == length(DataOrg{SelectedCh(i,2)}))
               handles.Data{i} = DataOrg{SelectedCh(i,1)}-DataOrg{SelectedCh(i,2)};
           else
               % Uneven sampling channel. Change data into 1st channel sampling rate.
               Temp1 = [0:1/length(DataOrg{SelectedCh(i,1)}):1-1/length(DataOrg{SelectedCh(i,1)})];
               Temp2 = [0:1/length(DataOrg{SelectedCh(i,2)}):1-1/length(DataOrg{SelectedCh(i,2)})];
               Temp = interp1(Temp2,DataOrg{SelectedCh(i,2)},Temp1); 
              
               handles.Data{i} = DataOrg{SelectedCh(i,1)}-Temp;
            end;
        end
    end   

    
function handles = MoveToLocation(handles)
   Temp = find((cumsum(handles.Files.EDFObj.getTotalTime)-handles.Display.StartTime)>0);
   %set(handles.ListBoxSegments,'value',Temp(1));

   %***********************************************************************
   Sel = get(handles.PopupDispWindow,'value');
   Temp1 = handles.Files.EDFObj.getTotalTime;
   Temp2 = get(handles.PopupDispWindow,'string');      
   Temp2 = str2num(Temp2{Sel}(1:end-3));
     
   % set slider window time parameters
   TempMax = Temp1(handles.Files.SelSegment) - Temp2;
   Temp = [0 cumsum(handles.Files.EDFObj.getTotalTime)];
   set(handles.SliderTime,'Min',Temp(handles.Files.SelSegment));
   set(handles.SliderTime,'value',Temp(handles.Files.SelSegment));
   set(handles.SliderTime,'Max',TempMax+Temp(handles.Files.SelSegment));

   set(handles.SliderTime,'SliderStep',[1 Temp2]/TempMax)

   Temp = handles.Display.StartTime;
   if Temp<0
       Temp=0;
   end

   if Temp>get(handles.SliderTime,'Max')
       set(handles.SliderTime,'value',get(handles.SliderTime,'Max'));
   else
       set(handles.SliderTime,'value',Temp);
   end;
   
   handles.Display.StartTime = get(handles.SliderTime,'value');

   %-----------------------------------------------------------------------
   %Set ListBRS and ListSpecBRS
   ScreenValue = [handles.Display.StartTime handles.Display.StartTime + Temp2];
      
   if(isempty(handles.Detect.R))
      return;
   end;
   Temp = handles.Display.StartTime+Temp2/2;

   try
      segType = get(handles.popupmenuSpecBRS,'value');
      if(segType == 1)
         idx = find(handles.Detect.SpectralBRS(:,end) == 0);      
      else
         idx = find(handles.Detect.SpectralBRS(:,end) ~= 0);      
      end;

      sel = get(handles.ListSpecBRS,'value');
      CmpWin = handles.Detect.SpectralBRS(sel,[1:2]);
      inSrcFlag = 1;
      if(CmpWin(2) < ScreenValue(1)) || (CmpWin(1) > ScreenValue(2))
         inSrcFlag = 0;
      end;

      if(~isempty(idx) && (inSrcFlag == 0)) 
         %idx1 = find(handles.Detect.SpectralBRS(idx,1) >= Temp,1,'first')      
         [~,idx1] = min(abs(handles.Detect.SpectralBRS(idx,1) - Temp) + abs(handles.Detect.SpectralBRS(idx,2) - Temp));
         if(~isempty(idx1))
            set(handles.ListSpecBRS,'value',idx1);
         else
            set(handles.ListSpecBRS,'value',length(idx));
         end;
      end;   
   catch e
   end;
   
   try
      idx = handles.Detect.BRSidx;
      segType = get(handles.popupmenuBRS,'value');
      if(segType == 1)
         idx1 = find(handles.Detect.BRSFlag == 0);
      elseif(segType == 2)
         idx1 = find(handles.Detect.BRSFlag == 10);
      else
         idx1 = find(handles.Detect.BRSFlag ~= 0);
      end;   
      idx = idx(idx1);   


      sel = get(handles.ListBRS,'value');
      CmpWin = handles.Detect.R(idx(sel),1);
      inSrcFlag = 1;
      if(CmpWin < ScreenValue(1)) || (CmpWin > ScreenValue(2))
         inSrcFlag = 0;
      end;

      if(~isempty(idx) && (inSrcFlag == 0))
         %idx1 = find(handles.Detect.R(idx,1) >= Temp,1,'first');
         [~,idx1] = min(abs(handles.Detect.R(idx,1) - Temp));
         if(~isempty(idx1))
            set(handles.ListBRS,'value',idx1);
         else
            set(handles.ListBRS,'value',length(idx));
         end;
      end;
   catch e
   end;
   %-----------------------------------------------------------------------
   
% --- Executes on slider movement.
function SliderTime_Callback(hObject, eventdata, handles)
   if(isempty(handles.Files.EDFObj))
      return;
   end;
   
   handles.Display.StartTime = get(hObject,'value');
   handles = MoveToLocation(handles);
   UpdateDisplaySetting(handles);
   handles = FileRead(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);
    

% --- Executes on selection change in listboxComment.
function listboxComment_Callback(hObject, eventdata, handles)
   Comment = handles.Files.EDFObj.getAnnotation;
   Sel = get(handles.listboxComment,'value');
   handles.Display.StartTime = min(Comment.Time{Sel}-handles.Display.Window/2,get(handles.SliderTime,'max'));
   handles = MoveToLocation(handles);
   handles = FileRead(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);
   
   
function genComment(handles)
   Comment = handles.Files.EDFObj.getAnnotation;
   
   AddTime = 0;
   Temp = {};
   for i = 1:length(Comment.Time)
      Temp1 = datestr((Comment.Time{i}+AddTime)/86400,'HH:MM:SS');
      Temp{end+1} = [Temp1 ' ' Comment.Text{i}];
   end;
   set(handles.listboxComment,'string',Temp,'value',1);

   
% --- Executes on selection change in popupmenuEKG.
function popupmenuEKG_Callback(hObject, eventdata, handles)
   sel = get(hObject,'value');
   handles.Display.SelectedCh(1,1) = sel - 1;
   handles = FileRead(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);


% --- Executes on selection change in popupmenuAbd.
function popupmenuAbd_Callback(hObject, eventdata, handles)
   sel = get(hObject,'value');
   handles.Display.SelectedCh(2,1) = sel - 1;
   handles = FileRead(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);
 
   
% --- Executes on selection change in popupmenuEKG2.
function popupmenuEKG2_Callback(hObject, eventdata, handles)
   sel = get(hObject,'value');
   handles.Display.SelectedCh(1,2) = sel - 1;
   handles = FileRead(handles);
   UpdatePlot(handles);
   guidata(hObject, handles);


% --------------------------------------------------------------------
% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
   Loc = get(hObject,'CurrentPoint');
   
   
% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
   Loc = get(hObject,'CurrentPoint');
   

function [Data,Fs] = getCmpData(handles,DataStart,DataEnd,SelectedCh)   
   DataLength = DataEnd - DataStart;

   if(DataLength < 0)
      DataLength = DataLength + 86400;
   end;
   
   % Additional code to not extract data from non-display channel (Speed up unless user want to display all channels)
   Temp = SelectedCh;
   Temp1 = unique(Temp); %Get distinct channel  
   Temp = find(Temp1); 
   Temp1 = Temp1(Temp); %Remove 0 from index

   DataOrg = handles.Files.EDFObj.FileRead(DataStart,DataLength,Temp1,handles.Files.SelSegment);

   %SelectedCh = handles.Display.SelectedCh;
   Data={};

   % construct the selected referential and differential channels
   for i=1:size(SelectedCh,1)
      if SelectedCh(i,1) == 0
         Data{i}=[];        
      elseif SelectedCh(i,2) == 0
         % referential
         Data{i}=DataOrg{SelectedCh(i,1)};
      else
         % differential
         if(length(DataOrg{SelectedCh(i,1)}) == length(DataOrg{SelectedCh(i,2)}))
            Data{i} = DataOrg{SelectedCh(i,1)}-DataOrg{SelectedCh(i,2)};
         else
            % Uneven sampling channel. Change data into 1st channel sampling rate.
            Temp1 = [0:1/length(DataOrg{SelectedCh(i,1)}):1-1/length(DataOrg{SelectedCh(i,1)})];
            Temp2 = [0:1/length(DataOrg{SelectedCh(i,2)}):1-1/length(DataOrg{SelectedCh(i,2)})];
            Temp = interp1(Temp2,DataOrg{SelectedCh(i,2)},Temp1); 

            Data{i} = DataOrg{SelectedCh(i,1)}-Temp;
         end;
      end
   end   
   
   %Extract Sampling rate
   FsEDF = handles.Files.EDFObj.getSamplingRate;
   for i = 1:size(SelectedCh,1)
      handles.Display.SelectedCh(i,1);
      if (handles.Display.SelectedCh(i,1) ~= 0)
         Fs(i) = FsEDF(handles.Display.SelectedCh(i,1));
      else
         Fs(i) = 0;
      end;
   end; 


function [BPIdx,BPSys,BPDias,BPAvg] = DetectBP(Data,Fs,rTime);
   BPMax = 250;
   BPMin = 20;
   
   rTime = fix(rTime*Fs);
   BPSys = zeros(length(rTime)-1,1);
   BPIdx = zeros(length(rTime)-1,1);

   for i = 1:(length(rTime)-1)
      [mVal,idx] = max(Data(rTime(i):rTime(i+1)));
      BPIdx(i) = rTime(i) + idx;
      BPSys(i) = mVal;
   end;
   
   BPAvg = BPSys;
   BPDias = BPSys;
   
   for i = 1:(length(BPIdx)-1)
      if(BPIdx(i) >= (BPIdx(i+1)-1))
         BPAvg(i) = mean(Data(BPIdx(i)));
         BPDias(i) = min(Data(BPIdx(i)));         
      else
         BPAvg(i) = mean(Data(BPIdx(i):(BPIdx(i+1)-1)));
         BPDias(i) = min(Data(BPIdx(i):(BPIdx(i+1)-1)));
      end;
   end;
   BPAvg(end) = NaN;
   BPDias(end) = NaN;

% --- Executes on selection change in ListBRS.
function ListBRS_Callback(hObject, eventdata, handles)
   if(isempty(handles.Detect.R))
      return;
   end;

   sel = get(handles.ListBRS,'value');
   idx = handles.Detect.BRSidx;

   segType = get(handles.popupmenuBRS,'value');
   if(segType == 1)
      idx1 = find(handles.Detect.BRSFlag == 0);
   elseif(segType == 2)
      idx1 = find(handles.Detect.BRSFlag == 10);
   else
      idx1 = find(handles.Detect.BRSFlag ~= 0);
   end;
   
   idx = idx(idx1);
   
   if(isempty(idx))
      return;
   end;

   set(handles.ButtonToggleBRS,'enable','off');
   if(handles.Detect.BRSFlag(idx1(sel)) == 0)||(handles.Detect.BRSFlag(idx1(sel)) == 10)
      set(handles.ButtonToggleBRS,'enable','on')
   end;
   
   Temp = max(fix(handles.Detect.BPTime(idx(sel)) - handles.Display.Window/2),0);
   
   handles.Display.StartTime = Temp;
   handles = MoveToLocation(handles);
   handles = FileRead(handles);
   UpdatePlot(handles);


% --------------------------------------------------------------------
% Save/Load data
% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
   if(isempty(handles.Files.Folder) || (handles.Files.CurFile == 0))
      return;
   end;
  
   curFile = [handles.Files.Folder handles.Files.FolderList{handles.Files.CurFile} ...
      handles.seperater handles.Files.FileList{handles.Files.CurFile}];
   curFile = getBRSName(curFile);
   
   if(exist(curFile, 'file') == 2)
      choice = questdlg('Would you like to overwrite existing computation?', ...
      'Confirmation', ...
      'Yes','No','Cancel','No');

      if(~strcmp(choice,'Yes'))
         return;
      end;
   end;
   
   h = waitbar(0,'Please wait...','WindowStyle','modal');    
   waitbar(1/3);   
      Display = handles.Display;
      Detect = handles.Detect;
      Parameters = handles.Parameters;
   waitbar(2/3);   
      save(curFile,'Display','Detect','Parameters')
   close(h);

function menuLoad_Callback(hObject, eventdata, handles)
   handles = LoadComputation(handles);
   guidata(hObject, handles);  
   UpdatePlot(handles);  
   UpdateDisplayParameter(handles);

function handles = LoadComputation(handles)
   if(isempty(handles.Files.Folder) || (handles.Files.CurFile == 0))
      return;
   end;
    
   curFile = [handles.Files.Folder handles.Files.FolderList{handles.Files.CurFile} ...
      handles.seperater handles.Files.FileList{handles.Files.CurFile}];
   curFile = getBRSName(curFile);
   disp(curFile)   
   if(exist(curFile, 'file') ~= 2)
      return;
   end;
   
   h = waitbar(0,'Please wait...','WindowStyle','modal');     
      load(curFile,'Display','Detect','Parameters')
      handles.Display = Display;
      handles.Detect = Detect;
      handles.Parameters = Parameters;
      set(handles.popupmenuEKG,'value',handles.Display.SelectedCh(1,1)+1);
      set(handles.popupmenuEKG2,'value',handles.Display.SelectedCh(1,2)+1);
   waitbar(1/4);   
   %Create Detection list for BRS
   CreateBRSList(handles);
   waitbar(2/4); 
   CreateSpecBRSList(handles);
   waitbar(3/4); 
   PlotBRSComputation(handles);
   waitbar(4/4); 
   handles = FileRead(handles);   
   close(h);

function out = getBRSName(in)
   out = in;
   out(end-3:end) = [];
   out = [out '_BRS.mat'];
function [outSpon, outSpec, outAnn, outParam] = getResultName(in)
   out = in;
   out(end-3:end) = [];
   outSpon = [out '_Spon.txt'];
   outSpec = [out '_Spec.txt'];
   outAnn = [out '_Ann.txt'];
   outParam = [out '_Param.txt'];
   
% --------------------------------------------------------------------
% Save/Load data
% --------------------------------------------------------------------


% --- Executes on button press in ButtonToggleBRS.
function ButtonToggleBRS_Callback(hObject, eventdata, handles)
   if(isempty(handles.Detect.R))
      return;
   end;

   sel = get(handles.ListBRS,'value');
   idx = handles.Detect.BRSidx;   
   
   segType = get(handles.popupmenuBRS,'value');
   if(segType == 1)
      txt = 'Would you like to remove selected segment from BRS computation?';    
      idx1 = find(handles.Detect.BRSFlag == 0);
      cVal = 10;
   elseif(segType == 2)
      txt = 'Would you like to include selected segment to BRS computation?';   
      idx1 = find(handles.Detect.BRSFlag == 10);
      cVal = 0;      
   end;   
   
   idx = idx(idx1);
   Temp = max(fix(handles.Detect.BPTime(idx(sel)) - handles.Display.Window/2),0);   
   handles.Display.StartTime = Temp;
   handles = MoveToLocation(handles);
  
   handles = FileRead(handles);
   UpdatePlot(handles);
   
   choice = questdlg(txt, 'Confirmation', 'Yes','No','Cancel','No');

   if(strcmp(choice,'Yes'))
      handles.Detect.BRSFlag(idx1(sel)) = cVal;%Manually removed

      CreateBRSList(handles);
      handles = MoveToLocation(handles);
      
      guidata(hObject, handles); 
      UpdatePlot(handles);
   end;


% --------------------------------------------------------------------
function menuSelectFolder_Callback(hObject, eventdata, handles)
   Temp = uigetdir(handles.Files.Folder,'Select EDF Folder');
   if(Temp ~= 0)
      handles.Files.Folder = Temp;
      set(handles.TextFolder,'String',Temp);

      h = waitbar(0,'1','Name','Progress');      
      waitbar(0,h,['Searching for ' handles.Files.Extension ' files...']);
      
      [handles.Files.FolderList, handles.Files.FileList] = findFile(handles.Files.Folder,'',handles.Files.Extension);
      N = length(handles.Files.FolderList);
      
      waitbar(1/5,h,['Building the list...']);      
      %Build file list
      Temp = {};
      for i = 1:N
         Temp{i} = [handles.Files.FolderList{i} handles.seperater handles.Files.FileList{i}];
         curEDF = EDF_File_Class([handles.Files.Folder Temp{i}]);
         Temp{i} = [Temp{i} ' [' curEDF.getStartDate ' ' curEDF.getStartTime ']'];
         waitbar(1/5 + 4/5*(i/N));          
      end;
      delete(h);
      
      handles.Files.CurFile = 0;
      
      set(handles.ListEDFFile,'String',Temp,'value',1);      
      guidata(hObject, handles);
   end;   


% --------------------------------------------------------------------
function menuProcess_Callback(hObject, eventdata, handles)
   StepNum = 10;   
   Tf = handles.Files.EDFObj.getTotalTime;
% handles.Parameters.EpochStep = 1;
% handles.Parameters.maxBP = 275;
   %-----------------------------------------------------------------------
   % Extract EKG data can detect R-peaks
   hWaitBar = waitbar(0,'Extracting EKG Data...','WindowStyle','modal'); 
   DataStart = 0;
   DataEnd = Tf;%min(Tf,maxWin);
   
   dIdx = 1;
   [Data,Fs] = getCmpData(handles,DataStart,DataEnd,handles.Display.SelectedCh(dIdx,:));

   waitbar(1/StepNum,hWaitBar,'Detecting R-peaks...')   

   %Down sampling data     
   N = fix(Fs(dIdx)/200);
   cFs = 200;
   cData = Data{dIdx}([1:N:length(Data{dIdx})]);
   rIdx = DetectR( cData,cFs )';
   handles.Detect.R = DataStart + (rIdx-1)/cFs;
   %-----------------------------------------------------------------------
   
   %-----------------------------------------------------------------------
   % Extract BP data can detect BP-features
   waitbar(2/StepNum,hWaitBar,'Extracting BP Data...')      
   %Detect Systolic BP
   DataStart = 0;
   DataEnd = Tf;

   dIdx = 2;
   [Data,Fs] = getCmpData(handles,DataStart,DataEnd,handles.Display.SelectedCh(dIdx,:));
   
   waitbar(3/StepNum,hWaitBar,'Extracting information from BP Data...') 
   [BPIdx,handles.Detect.BPSys,handles.Detect.BPDias,handles.Detect.BPAvg] = DetectBP( Data{1},Fs(1),handles.Detect.R );

   handles.Detect.BPTime = DataStart + (BPIdx-1)/Fs(1);
   handles.Detect.Flag = handles.Detect.BPTime*0;
   Temp = handles.Files.EDFObj.getPhysicalUnit;
   handles.Detect.BPUnit = Temp{handles.Display.SelectedCh(2,1)};

   %-----------------------------------------------------------------------     
   
   %-----------------------------------------------------------------------
   % Clean up "bad" data based on BP and PAT criteria
   PAT = 1000*(handles.Detect.BPTime - handles.Detect.R(1:end-1));
      
   %BP criteria
   idx = find(handles.Detect.BPSys > handles.Parameters.maxBP);
   handles.Detect.Flag(idx) = handles.Detect.Flag(idx) + 1;
   idx = find(handles.Detect.BPSys < handles.Parameters.minBP);
   handles.Detect.Flag(idx) = handles.Detect.Flag(idx) + 1;

   %PAT criteria
   idx = find(PAT < handles.Parameters.cndPAT);
   handles.Detect.Flag(idx) = handles.Detect.Flag(idx) + 1;
   
   %PAT criteria 2
   blockSize = 10;
   for i = 1:length(PAT) - blockSize
      curMean = mean(PAT(i:i+blockSize-1));
      idx = find(abs(PAT(i:i+blockSize-1) - curMean) > handles.Parameters.cndPAT);
      handles.Detect.Flag(idx + i - 1) = handles.Detect.Flag(idx + i - 1) + 1;
   end;
   %-----------------------------------------------------------------------    
   
   %-----------------------------------------------------------------------
   % Clear all parameters for BRS Computation
   handles.Detect.BRSidx = [];
   handles.Detect.BRSFlag = [];
   handles.Detect.Slope = [];
   handles.Detect.Rsquare = [];
   set(handles.ListBRS,'string','-','value',1);   
   %-----------------------------------------------------------------------
   
   %-----------------------------------------------------------------------
   % Compute Spontaneous BRS
   waitbar(5/StepNum,hWaitBar,'Computing Spontaneous BRS...')
   W = ones(handles.Parameters.SegLen,1);
   W2 = ones(handles.Parameters.SegLen+1,1);

   BPChange = sign(diff(handles.Detect.BPSys));
   Temp = conv(BPChange,W);
   Temp = Temp(handles.Parameters.SegLen:end);

   RR = diff(handles.Detect.R);
   cFlag = (abs(Temp) == handles.Parameters.SegLen);% .* (abs(Temp1) == handles.Parameters.SegLen); 
      
   idx = find(cFlag == 1);
   handles.Detect.BRSidx = idx; 
   handles.Detect.BRSFlag = idx*0;
   handles.Detect.Rsquare = idx*0;
   handles.Detect.Slope = idx*0;
   handles.Detect.SpectralBRS = [];
      
   cMap = {'Decrease','Increase'};
   for i = 1:length(idx)      
      try
         Seg_BP = handles.Detect.BPSys([0:handles.Parameters.SegLen]+idx(i));
         Seg_RR = RR([0:handles.Parameters.SegLen]+idx(i)+handles.Parameters.Delay);
                  
         maxBPChange = max(abs(diff(Seg_BP)));
         maxHRChange = max(abs(diff(60./Seg_RR)));
         
         %Compute slope and R-square
         Temp1 = corrcoef(Seg_BP,Seg_RR);
         handles.Detect.Rsquare(i) = (Temp1(2)*Temp1(2));    
         Temp1=polyfit(Seg_BP,Seg_RR,1);
         handles.Detect.Slope(i) = Temp1(1)*1000; %Convert Slope to millisecond     

         fBP = sum(handles.Detect.Flag([0:handles.Parameters.SegLen]+idx(i)) == 0);
         fHR = sum(handles.Detect.Flag([0:handles.Parameters.SegLen+1]+idx(i)+handles.Parameters.Delay) == 0);
      catch e
         handles.Detect.BRSFlag(i) = 400; %Not enough HR data
         continue;
      end;
      
      %[fBP fHR]
      if(fBP < handles.Parameters.SegLen+1) || (fHR < handles.Parameters.SegLen+2)
         handles.Detect.BRSFlag(i) = 404; %Containing bad data
         continue;         
      end;

      RRChange = sign(diff(Seg_RR));
      RRChange = abs(sum(RRChange));
      if(abs(RRChange) ~= handles.Parameters.SegLen)
         handles.Detect.BRSFlag(i) = 201; %Non uniform change in HR
         continue;
      end;
      
      if(handles.Detect.Slope(i) < 0)
         handles.Detect.BRSFlag(i) = 202; %Wrong Slope
         continue;
      end;
                 
      if(handles.Detect.Rsquare(i) < handles.Parameters.R2Lim)
         handles.Detect.BRSFlag(i) = 101; %Fail in R-square condition
         continue;         
      end; 
      
      if(abs(handles.Detect.Slope(i)) > handles.Parameters.SlopeLim)
         handles.Detect.BRSFlag(i) = 102; %Fail Slope Criteria
         continue;
      end;    

      if(maxBPChange > handles.Parameters.BPChangeLim)
         handles.Detect.BRSFlag(i) = 103; %Fail Slope Criteria
         continue;
      end;
      if(maxHRChange > handles.Parameters.HRChangeLim)
         handles.Detect.BRSFlag(i) = 104; %Fail Slope Criteria
         continue;
      end;
   end;
   %-----------------------------------------------------------------------
   
   %-----------------------------------------------------------------------
   % Store Paramter for current computation
   handles.Detect.Parameters = handles.Parameters;
   %-----------------------------------------------------------------------
      
   %-----------------------------------------------------------------------
   % Create list for BRS segments
   CreateBRSList(handles);
   %-----------------------------------------------------------------------
   
   %-----------------------------------------------------------------------
   % Compute Spectral BRS
   idx = find(handles.Detect.Flag ~= 0);
   idx = unique([1; idx; length(handles.Detect.Flag)]);
   clc;
   
   for i = 1:(length(idx)-1)      
      EpochStart = handles.Detect.R(idx(i) + 1);
      EpochEnd = handles.Detect.R(idx(i+1) - 1);      
      Duration = EpochEnd - EpochStart;
      
      if(Duration >= handles.Parameters.EpochSize)
         SubEpochStart = EpochStart;
         SubEpochEnd = SubEpochStart + handles.Parameters.EpochSize;
         while(SubEpochEnd < EpochEnd)            
            idx1 = find(handles.Detect.R > SubEpochStart,1,'first');
            idx2 = find(handles.Detect.R < SubEpochEnd,1,'last');
            
            if((idx2 - idx1) < 0.5*handles.Parameters.EpochSize) %In sufficient data point
               %Move to next sub-Epoch
               SubEpochStart = SubEpochStart + handles.Parameters.EpochStep;
               SubEpochEnd = SubEpochEnd + handles.Parameters.EpochStep;
            
               continue;
            end;
                        
            [BP, HR_RR, HR_BPM, STDHR_RR, STDHR_BPM, RMSSD, SDSD, HR_LF, HR_HF, BP_LF, BP_HF, BRS_LF, BRS_HF] = ...
               fnctComputeBRS(handles.Detect.R(idx1:idx2),handles.Detect.BPTime(idx1:idx2),handles.Detect.BPSys(idx1:idx2));
            
            %Last column in [handles.Detect.SpectralBRS]
            % 0:         indicate the auto-detection result
            % otherwise: indicate input from user
            handles.Detect.SpectralBRS(end+1,:) = [SubEpochStart, SubEpochEnd, BP, HR_RR, HR_BPM, STDHR_RR, STDHR_BPM, RMSSD, SDSD, HR_LF, HR_HF, BP_LF, BP_HF, BRS_LF, BRS_HF, 0];

            %Move to next sub-Epoch
            SubEpochStart = SubEpochStart + handles.Parameters.EpochStep;
            SubEpochEnd = SubEpochEnd + handles.Parameters.EpochStep;
         end;
      end;
   end;

   %Create a list for spectral BRS
   CreateSpecBRSList(handles)
   %-----------------------------------------------------------------------
   
   %-----------------------------------------------------------------------
   % Plot BRS
   PlotBRSComputation(handles);
   %-----------------------------------------------------------------------
   
   delete(hWaitBar)   
   
   UpdatePlot(handles);
   guidata(hObject, handles);  

   
function PlotBRSComputation(handles)
   if(isempty(handles.Detect.R(1)))
      return;
   end;
   
   sel = get(handles.ListResultPlot,'value');

   axes(handles.axesBRS);
   cla;   
   PlotScale = 0.8;
   PlotShift = 0.5-PlotScale/2;
   
   xRange = [0  handles.Files.EDFObj.getTotalTime];
   switch sel
      case 1                 
         %Plot heart rate                  
         curData = diff(handles.Detect.R);         
         PlotSingleResult(handles.Detect.R(1:end-1),60*curData.^-1,[],PlotScale,1,'Heart Rate',0,[20 120],xRange);                  
         
         %Plot BP
         curData = [handles.Detect.BPSys, handles.Detect.BPDias, handles.Detect.BPAvg];
         PlotSingleResult(handles.Detect.R(1:end-1),curData,handles.Detect.Flag,PlotScale,0,'Blood Pressure',0,[30 200],xRange); 
         
         ylim([0 2]);
      case 2
         idx = find((handles.Detect.BRSFlag == 0) + (handles.Detect.BRSFlag == 10));
         %Plot spontaneous BRS         
         PlotSingleResult(handles.Detect.BPTime(handles.Detect.BRSidx(idx)),handles.Detect.Slope(idx),...
            [],PlotScale,0,'Spontaneous BRS',1,[],xRange);         
         ylim([0 1]);
      case 3     
         idx = find((handles.Detect.SpectralBRS(:,end) == 0) + (handles.Detect.SpectralBRS(:,end) == 10));
         %Plot STD HR                             
         PlotSingleResult(handles.Detect.SpectralBRS(idx,1),handles.Detect.SpectralBRS(idx,2+4),...
            [],PlotScale,2,'STD Heart Rate',1,[],xRange);
         
         %Plot RMSSD
         PlotSingleResult(handles.Detect.SpectralBRS(idx,1),handles.Detect.SpectralBRS(idx,2+6),...
            [],PlotScale,1,'RMSSD Heart Rate',1,[],xRange);
         
         %Plot RMSSD
         PlotSingleResult(handles.Detect.SpectralBRS(idx,1),handles.Detect.SpectralBRS(idx,2+7),...
            [],PlotScale,0,'SDSD Heart Rate',1,[],xRange);
        
         ylim([0 3]);
      case 4      
         idx = find((handles.Detect.SpectralBRS(:,end) == 0) + (handles.Detect.SpectralBRS(:,end) == 10));
         %Plot HF BRS                    
         PlotSingleResult(handles.Detect.SpectralBRS(idx,1),handles.Detect.SpectralBRS(idx,end-1),...
            [],PlotScale,1,'HF BRS',1,[],xRange);
         
         %Plot LF BRS
         PlotSingleResult(handles.Detect.SpectralBRS(idx,1),handles.Detect.SpectralBRS(idx,end-2),...
            [],PlotScale,0,'LF BRS',1,[],xRange);
         
         ylim([0 2]);
      case 5
         idx = find((handles.Detect.SpectralBRS(:,end) == 0) + (handles.Detect.SpectralBRS(:,end) == 10));
         %Plot HF BP                   
         PlotSingleResult(handles.Detect.SpectralBRS(idx,1),handles.Detect.SpectralBRS(idx,end-3),...
            [],PlotScale,1,'HF BP',1,[],xRange);
         
         %Plot LF BP
         PlotSingleResult(handles.Detect.SpectralBRS(idx,1),handles.Detect.SpectralBRS(idx,end-4),...
            [],PlotScale,0,'LF BP',1,[],xRange);
         
         ylim([0 2]);
      case 6
         %Plot HF HR                    
         PlotSingleResult(handles.Detect.SpectralBRS(:,1),handles.Detect.SpectralBRS(:,end-5),...
            [],PlotScale,1,'HF HR',1,[],xRange);
         
         %Plot LF HR
         PlotSingleResult(handles.Detect.SpectralBRS(:,1),handles.Detect.SpectralBRS(:,end-6),...
            [],PlotScale,0,'LF HR',1,[],xRange);
         
         ylim([0 2]);         
   end;   
   
   set(gca,'xtick',[],'ytick',[]);
   xlim([0, handles.Files.EDFObj.getTotalTime])

   
function PlotSingleResult(Time,Value,Flag,PlotScale,PlotNum,Text,Type,yRange,xRange)
   [row, sigNum] = size(Value);
   meanVal = zeros(1,sigNum);
   stdVal = zeros(1,sigNum);
   
   if(nargin < 8) || isempty(yRange)
      for i = 1:sigNum
         idx = find(~isnan(Value(:,i)));
         meanVal(i) = mean(Value(idx,i));
         stdVal(i) = std(Value(idx,i));

         idx = find( (Value(:,i) < (meanVal(i)+2*stdVal(i)) ) .*  ...
            (Value(:,i) > (meanVal(i)-2*stdVal(i)) ));
         meanVal(i) = mean(Value(idx,i));
         stdVal(i) = std(Value(idx,i));      
      end;
      maxPlot = max(meanVal)+3*max(stdVal);   
      minPlot = min(meanVal)-3*max(stdVal);  
   else
      maxPlot = max(yRange);   
      minPlot = min(yRange);        
   end;
   
   rangePlot = maxPlot - minPlot;
   PlotShift = 0.5-PlotScale/2;
   
   if(rangePlot ~= 0)
      Value = PlotScale * (Value-minPlot)/rangePlot;
   end;
   
   if(isempty(Flag))
      Flag = 0*Value;
   end;

   hold on;
   if(nargin < 9)
      tLine = [fix(Time(1)) round(Time(end))];
   else
      tLine = xRange;
   end;
   line(tLine,[1 1] + PlotNum - PlotShift,'Color',[0.5 0.5 0.5],'LineWidth',0.5);
   line(tLine,[0 0] + PlotNum + PlotShift,'Color',[0.5 0.5 0.5],'LineWidth',0.5);
   
   PlotShift = PlotShift + PlotNum;
   if(Type == 0)
      plot(Time,Value+PlotShift);
   else
      plot(Time,Value+PlotShift,'.-');
   end;
   idx = find(Flag ~= 0);
   plot(Time(idx),Value(idx,:)+PlotShift,'r.');
   text(0.01*diff(tLine),PlotNum+0.2,['\bf ' Text])
   hold off;
   
   
% --------------------------------------------------------------------
function menuExport_Callback(hObject, eventdata, handles) 
   if(isempty(handles.Detect.R))      
      return;
   end;
   Tab = char(9);

   choice = questdlg({'Would you like to export computational result to',['     [' handles.Files.ResultFolder ']?']}, ...
   'Confirmation', ...
   'Yes','No','Cancel','No');

   if(~strcmp(choice,'Yes'))
      return;
   end;   

   curFile = [handles.Files.ResultFolder handles.Files.FolderList{handles.Files.CurFile} ...
      handles.seperater handles.Files.FileList{handles.Files.CurFile}];   
   
   [outSpon, outSpec, outAnn, outParam] = getResultName(curFile);

   %Heart rate
   HRAll = zeros(length(handles.Detect.R)-1,3);
   HRAll = [handles.Detect.R(1:end-1) ,diff(handles.Detect.R), 60*diff(handles.Detect.R).^-1];
   
   %Blood pressure
   BPAll = zeros(length(handles.Detect.BPTime),3);
   BPAll = [handles.Detect.BPTime ,handles.Detect.BPSys, handles.Detect.BPDias, handles.Detect.BPAvg];
   
   BPUnit = handles.Detect.BPUnit;
   
   %-----------------------------------------------------------------------
   %Spontaneous BRS 
   try
      idx = handles.Detect.BRSidx;
      idx1 = find(handles.Detect.BRSFlag == 0);
      idx = idx(idx1);   
      SponAll = [handles.Detect.BPTime(idx), handles.Detect.R(idx+handles.Parameters.Delay+handles.Parameters.SegLen),...
         handles.Detect.Slope(idx1), sign(handles.Detect.BPSys(idx+1)-handles.Detect.BPSys(idx))];

      idx = handles.Detect.BRSidx;
      idx1 = find(handles.Detect.BRSFlag ~= 0);
      idx = idx(idx1);
      SponAllBad = [handles.Detect.BPTime(idx), handles.Detect.R(idx+handles.Parameters.Delay+handles.Parameters.SegLen),...
         handles.Detect.Slope(idx1), sign(handles.Detect.BPSys(idx+1)-handles.Detect.BPSys(idx))];
   catch e  
      SponAll = [];
      SponAllBad = [];
   end;
   %Export output
   Fid = fopen(outSpon,'w');
   fprintf(Fid,['Start(s)' Tab 'End(s)' Tab 'Slope(ms/' BPUnit ')' Tab 'Direction\r\n']);
   for i = 1:size(SponAll,1)
      for j = 1:(size(SponAll,2)-1)  
         fprintf(Fid,'%f\t',SponAll(i,j));
      end;
      fprintf(Fid,'%d\r\n',SponAll(i,end));
   end;
   fclose(Fid);   
   %-----------------------------------------------------------------------
   %-----------------------------------------------------------------------
   %Spectral BRS
   try
      idx = find(handles.Detect.SpectralBRS(:,end) == 0);  
      SpecAll = handles.Detect.SpectralBRS(idx,:);

      idx = find(handles.Detect.SpectralBRS(:,end) ~= 0);  
      SpecAllBad = handles.Detect.SpectralBRS(idx,:);
   catch e
      SpecAll = [];
      SpecAllBad = [];
   end;

   %Export output
   Fid = fopen(outSpec,'w');
   fprintf(Fid,['Start(s)' Tab 'End(s)' Tab 'BP(mmHg)' Tab 'RR(ms)' Tab 'HR(BPM)' Tab...
      'STDRR(ms)' Tab 'STDHR(BPM)' Tab 'RMSSD(ms)' Tab 'SDSD(ms)' Tab 'HR_LF(ms^2)' Tab...
      'HR_HF(ms^2)' Tab 'BP_LF(' BPUnit '^2)' Tab 'BP_HF(' BPUnit '^2)' Tab ...
      'BRS_LF(ms^2/' BPUnit '^2)' Tab 'BRS_HF(ms^2/' BPUnit '^2)' Tab '\r\n']);
   for i = 1:size(SpecAll,1)
      for j = 1:(size(SpecAll,2)-1)         
         fprintf(Fid,'%f\t',SpecAll(i,j));
      end;
      fprintf(Fid,'\r\n');
   end;
   fclose(Fid);
   %-----------------------------------------------------------------------
   %-----------------------------------------------------------------------
   %Annotations
   Comment = handles.Files.EDFObj.getAnnotation;
   %Export output
   Fid = fopen(outAnn,'w');
   fprintf(Fid,['Time(s)' Tab 'Annotations\r\n']);
   for i = 1:length(Comment.Time)
      fprintf(Fid,'%f\t%s\r\n',Comment.Time{i},Comment.Text{i});
   end;
   fclose(Fid);
   %-----------------------------------------------------------------------
   
   %-----------------------------------------------------------------------
   %Parameters
   Parameters = handles.Detect.Parameters;
   Fid = fopen(outParam,'w');
   fprintf(Fid,'Spontaneous Baroreflex Parameters\r\n');
      fprintf(Fid,'\tSample Delay:\t%d samples\r\n',Parameters.Delay);
      fprintf(Fid,'\tSegment Length:\t%d samples\r\n',Parameters.SegLen);
      fprintf(Fid,'\tSlope Limit:\t%f ms/mmHg\r\n',Parameters.SlopeLim);
      fprintf(Fid,'\tHeart Rate Change Limit:\t%f BPM\r\n',Parameters.BPChangeLim);
      fprintf(Fid,'\tBlood Pressure Change Limit:\t%f mmHg\r\n',Parameters.HRChangeLim);
      fprintf(Fid,'\tMinimum R-Square:\t%f\r\n',Parameters.R2Lim); 
   fprintf(Fid,'Spectral Baroreflex Parameters\r\n');
      fprintf(Fid,'\tEpoch Size:\t%f seconds\r\n',Parameters.EpochSize); 
      fprintf(Fid,'\tComputation Step:\t%f seconds\r\n',Parameters.EpochStep); 
   fprintf(Fid,'Signal Parameters\r\n');
      fprintf(Fid,'\tMaximum Blood Pressure:\t%f mmHg\r\n',Parameters.maxBP); 
      fprintf(Fid,'\tMinimum Blood Pressure:\t%f mmHg\r\n',Parameters.minBP); 
      fprintf(Fid,'\tPAT Condition:\t%f ms\r\n',Parameters.cndPAT);              
   fclose(Fid);
   %-----------------------------------------------------------------------
   disp('')
   uiwait(msgbox({'Complete Exporting Computational Results to',['     [' handles.Files.ResultFolder '].']},'Success','modal'));
   
% --- Executes on selection change in popupmenuBRS.
function popupmenuBRS_Callback(hObject, eventdata, handles)
   CreateBRSList(handles);

   
function [BP, HR_RR, HR_BPM, STDHR_RR, STDHR_BPM, RMSSD, SDSD, HR_LF, HR_HF, BP_LF, BP_HF, BRS_LF, BRS_HF] = fnctComputeBRS(R_Time,BP_Time,BP_Sys)
%--------------------------------------------------------------------------
%Input argument
%   R_Time:  Time of r-peak from EKG signal
%   BP_Time: Time of systolic blood pressure from BP signal
%   BP_Sys:  Value of systolic blood pressure at BP_Time
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Output argument
%   HR:        Average heart rate in second
%   HR_BPM:    Average heart rate in beat-per-minute
%   STDHR:     Standard deviation of heart rate in second
%   STDHR_BPM: Standard deviation of heart rate in beat-per-minute
%   RMSSD:     Root mean square of the different in heart rate in second
%   SDSD:      Standard deviation of the different in heart rate in second      
%   HR_LF:     Low frequency of heart rate
%   HR_HF:     High frequency of heart rate
%   BP_LF:     Low frequency of systolic blood pressure
%   BP_HF:     High frequency of systolic blood pressure
%   BRS_LF:    Low frequency of spectral baroreflex
%   BRS_HF:    High frequency of spectral baroreflex
%--------------------------------------------------------------------------
   try
      %Compute heart rate   
      R_R = diff(R_Time)*1000; %Convert it to millisecond

      BP = mean(BP_Sys);

      %Compute HRV
      HR_RR = mean(R_R);
      HR_BPM = mean(R_R.^-1 * 60 * 1000);
      STDHR_RR = std(R_R);
      STDHR_BPM = std(R_R.^-1 * 60 * 1000);
      RMSSD = sqrt(mean(diff(R_R).^2));
      SDSD = std(diff(R_R));    

      %Make sure that every data have the same length
      R_Time = R_Time(1:end-1);
      BP_Time = BP_Time(1:end-1);
      BP_Sys = BP_Sys(1:end-1);

      HF_Range = [0.15 0.4];
      LF_Range = [0.04 0.15];

      %Compute Lomb-Scargle normalized periodogram for heart rate
%       [WK1 WK2 JMAX PROB]=FASPER(R_Time,R_R - mean(R_R));
%       WK1_R = WK1;
%       WK2_R = WK2*var(R_R); %Include actual physical unit
      [WK2_R,WK1_R] = plomb(R_R - mean(R_R),R_Time); %Matlab tool box            
      
      %Compute Lomb-Scargle normalized periodogram for systolic BP
%       [WK1 WK2 JMAX PROB]=FASPER(BP_Time,BP_Sys-mean(BP_Sys));
%       WK2 = WK2*var(BP_Sys); %Include actual physical unit
      [WK2,WK1] = plomb(BP_Sys-mean(BP_Sys),BP_Time); %Matlab tool box

      % WK1 is frequency information of BP
      % WK1_R is frequency information of HR
      % WK2 is spectrum associated with WK1 for BP
      % WK2_R is spectrum associated with WK1_R for HR   

      BRS = WK2_R./WK2;

      Index = find(WK1<LF_Range(1));
      WK2(Index) = 0;
      WK2_R(Index) = 0;

      dWK = diff(WK1);

      Temp = HF_Range;
      Index = find(WK1>Temp(1) & WK1<Temp(2));%find(WK1>Temp(1) & WK1<Temp(2) & BRS>0.2);
      Temp = find(Index>length(dWK));
      Index(Temp) = [];
      BRS_HF = sum(BRS(Index).*dWK(Index));%mean(BRS(Index));
      BP_HF = sum(WK2(Index).*dWK(Index));%mean(WK2(Index));
      HR_HF= sum(WK2_R(Index).*dWK(Index));%mean(WK2_R(Index));

      Temp = LF_Range;
      Index = find(WK1>Temp(1) & WK1<Temp(2));%find(WK1>Temp(1) & WK1<Temp(2) & BRS>0.2);
      Temp = find(Index>length(dWK));
      Index(Temp) = [];  
      BRS_LF = sum(BRS(Index).*dWK(Index));%mean(BRS(Index));
      BP_LF = sum(WK2(Index).*dWK(Index));%mean(WK2(Index));
      HR_LF = sum(WK2_R(Index).*dWK(Index));%mean(WK2_R(Index));
   catch e
      BP = NaN;
      HR = NaN;
      HR_BPM = NaN;
      STDHR = NaN;
      STDHR_BPM = NaN;
      RMSSD = NaN;
      SDSD = NaN;
      HR_LF = NaN;
      HR_HF = NaN;
      BP_LF = NaN;
      BP_HF = NaN;
      BRS_LF = NaN;
      BRS_HF = NaN;
   end;

% --- Executes on selection change in ListSpecBRS.
function ListSpecBRS_Callback(hObject, eventdata, handles)   
   if(isempty(handles.Detect.R))
      return;
   end;

   sel = get(handles.ListSpecBRS,'value');

   segType = get(handles.popupmenuSpecBRS,'value');
   if(segType == 1)
      idx = find(handles.Detect.SpectralBRS(:,end) == 0);      
   else
      idx = find(handles.Detect.SpectralBRS(:,end) ~= 0);      
   end;
   
   if(isempty(idx))
      return;
   end;
   
   Temp = max(fix(handles.Detect.SpectralBRS(idx(sel),1) - handles.Display.Window/2),0);
   
   handles.Display.StartTime = Temp;
   handles = MoveToLocation(handles);
   handles = FileRead(handles);
   UpdatePlot(handles);
   

% --- Executes on button press in ButtonToggleSpecBRS.
function ButtonToggleSpecBRS_Callback(hObject, eventdata, handles)
   if(isempty(handles.Detect.R))
      return;
   end;

   sel = get(handles.ListSpecBRS,'value');
   %idx = handles.Detect.BRSidx;   
   
   segType = get(handles.popupmenuSpecBRS,'value');
   if(segType == 1)
      txt = 'Would you like to remove selected segment from BRS computation?';    
      idx = find(handles.Detect.SpectralBRS(:,end) == 0);
      cVal = 10;
   else
      txt = 'Would you like to include selected segment to BRS computation?';   
      idx = find(handles.Detect.SpectralBRS(:,end) ~= 0);
      cVal = 0;
   end;   
   
   Temp = max(fix(handles.Detect.SpectralBRS(idx(sel),1) - handles.Display.Window/2),0);   
   handles.Display.StartTime = Temp;
   handles = MoveToLocation(handles);
  
   handles = FileRead(handles);
   UpdatePlot(handles);
   
   choice = questdlg(txt, 'Confirmation', 'Yes','No','Cancel','No');

   if(strcmp(choice,'Yes'))
      handles.Detect.SpectralBRS(idx(sel),end) = cVal;%Manually removed
      
      CreateSpecBRSList(handles);
      handles = MoveToLocation(handles);
      
      guidata(hObject, handles); 
      UpdatePlot(handles);
   end;

% --- Executes on selection change in popupmenuSpecBRS.
function popupmenuSpecBRS_Callback(hObject, eventdata, handles)
   CreateSpecBRSList(handles);


function CreateBRSList(handles)
   segType = get(handles.popupmenuBRS,'value');
   Temp = {'-'};   
   if(segType == 1)
      idx = find(handles.Detect.BRSFlag == 0);
   elseif(segType == 2)
      idx = find(handles.Detect.BRSFlag == 10);
   else
      idx = find(handles.Detect.BRSFlag ~= 0);
   end;
   BPChange = sign(diff(handles.Detect.BPSys));
   
   cMap = {'Decrease','Increase'};
   for i = 1:length(idx)  
      BPidx = handles.Detect.BRSidx(idx(i)); 
      %Create list
      Temp{i} = ['Time:' datestr(handles.Detect.BPTime(BPidx)/86400,'HH:MM:SS')];
      Temp{i} = [Temp{i} ', Rsqr:' num2str(handles.Detect.Rsquare(idx(i)),'%.2f')];
      Temp{i} = [Temp{i} ', Slope:' num2str(handles.Detect.Slope(idx(i)),'%.2f')];
      Temp{i} = [Temp{i} ', BP-' cMap{(BPChange(BPidx)+3)/2}];
   end;
   set(handles.ListBRS,'string',Temp,'value',1)
   
   
function CreateSpecBRSList(handles)
   segType = get(handles.popupmenuSpecBRS,'value');

   Temp = {'-'};   
   if(isempty(handles.Detect.SpectralBRS))
      idx = [];
   elseif(segType == 1)
      idx = find(handles.Detect.SpectralBRS(:,end) == 0);
   else
      idx = find(handles.Detect.SpectralBRS(:,end) ~= 0);
   end;

   for i = 1:length(idx)  
      %Create list
      Temp{i} = ['Time:' datestr(handles.Detect.SpectralBRS(idx(i),1)/86400,'HH:MM:SS')];
      Temp{i} = [Temp{i} ' - ' datestr(handles.Detect.SpectralBRS(idx(i),2)/86400,'HH:MM:SS')];
   end;
   set(handles.ListSpecBRS,'string',Temp,'value',1)


% --- Executes on selection change in ListResultPlot.
function ListResultPlot_Callback(hObject, eventdata, handles)
   PlotBRSComputation(handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   if(isempty(handles.Files.EDFObj))
      return;
   end;

   Loc = get(handles.axesBRS,'CurrentPoint');
   curX = Loc(1,1);
   curY = Loc(1,2);
      
   sel = get(handles.ListResultPlot,'value');
   
   switch sel
      case {1,3,4,5}
         dispChNum = 2;
      case 2
         dispChNum = 3;
      otherwise
         dispChNum = 100;
   end;
   
   if (0 <= curX) && (curX <= handles.Files.EDFObj.getTotalTime) && (0 <= curY) && (curY <= dispChNum) %&& curMode 
      %Place holder
   else
      return; %User click outside the screen. Nothing to do...
   end;

   handles.Display.StartTime = fix(curX);
   handles = MoveToLocation(handles);   
   handles = FileRead(handles);
   UpdatePlot(handles);


% --------------------------------------------------------------------
function menuPlotHR_Callback(hObject, eventdata, handles)
   if(~isempty(handles.Detect.R))  
      figure;
      HR = 60 * diff(handles.Detect.R).^-1;
      plot(handles.Detect.R(1:end-1),HR)
      ylabel('Heart Rate (BPM)')
      SetAbsTime(handles);
      xlim([handles.Detect.BPTime(1) handles.Detect.BPTime(end-1)]);
   end;


% --------------------------------------------------------------------
function menuPlotBP_Callback(hObject, eventdata, handles)
   if(~isempty(handles.Detect.BPTime))  
      figure;
      plot(handles.Detect.BPTime,handles.Detect.BPSys,...
         handles.Detect.BPTime,handles.Detect.BPDias,...
         handles.Detect.BPTime,handles.Detect.BPAvg)
      legend('Systolic','Diastolic','Average')
      ylabel('Blood Pressure (mmHg)')
      SetAbsTime(handles);
      xlim([handles.Detect.BPTime(1) handles.Detect.BPTime(end)]);
   end;


% --------------------------------------------------------------------
function menuSelectExportFolder_Callback(hObject, eventdata, handles)
   Temp = uigetdir(handles.Files.ResultFolder,'Select EDF Folder');
   if(Temp ~= 0)
      handles.Files.ResultFolder = Temp;
   end;
   guidata(hObject, handles); 
   %handles.Files.ResultFolder
   %handles.Files.Folder


% -------------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)
   choice = questdlg('Would you like to close the program?', ...
   'Confirmation', ...
   'Yes','No','Cancel','No');

   if(strcmp(choice,'Yes'))
      close;
   end;
   


% -------------------------------------------------------------------------
% Parameter Adjustment
function EditDelay_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');
   
   val = str2num(text);
   if(isempty(val))
      val = 1;
   else
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.Delay = val;
   guidata(hObject, handles);

function EditSegLen_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');   
      
   val = str2num(text);
   if(isempty(val))
      val = 3;
   else
      val = max(val,3);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.SegLen = val;
   guidata(hObject, handles);

function EditSlopeLim_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');
   
   val = str2num(text);
   if(isempty(val))
      val = 100;
   else
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.SlopeLim = val;
   guidata(hObject, handles);

function EditHRChangeLim_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');
   
   val = str2num(text);
   if(isempty(val))
      val = 40;
   else
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.HRChangeLim = val;
   guidata(hObject, handles);
   
function EditBPChangeLim_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');
   
   val = str2num(text);
   if(isempty(val))
      val = 40;
   else
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.BPChangeLim = val;
   guidata(hObject, handles);
   
function EditR2Lim_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');

   val = str2num(text);
   if(isempty(val))
      val = 0.8;
   else
      val = min(val,1);
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.R2Lim = val;
   guidata(hObject, handles);

function EditEpochSize_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');

   val = str2num(text);
   if(isempty(val))
      val = 120;
   else
      val = max(val,120);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.EpochSize = val;
   guidata(hObject, handles);
   
function EditEpochStep_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');

   val = str2num(text);
   if(isempty(val))
      val = 120;
   else
      val = max(val,1);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.EpochStep = val;
   guidata(hObject, handles);

function EditMaxBP_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');

   val = str2num(text);
   if(isempty(val))
      val = 275;
   else
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.maxBP = val;
   guidata(hObject, handles);
   
function EditMinBP_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');

   val = str2num(text);
   if(isempty(val))
      val = 20;
   else
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.minBP = val;
   guidata(hObject, handles);


function EditPATThreshold_Callback(hObject, eventdata, handles)
   text = get(hObject,'string');

   val = str2num(text);
   if(isempty(val))
      val = 150;
   else
      val = max(val,0);
   end;

   text = num2str(val);
   set(hObject,'string',text);
   handles.Parameters.cndPAT = val;
   guidata(hObject, handles);

function UpdateDisplayParameter(handles)
   set(handles.EditDelay,'string',num2str(handles.Parameters.Delay));
   set(handles.EditSegLen,'string',num2str(handles.Parameters.SegLen));
   set(handles.EditR2Lim,'string',num2str(handles.Parameters.R2Lim));
   set(handles.EditSlopeLim,'string',num2str(handles.Parameters.SlopeLim));
   set(handles.EditBPChangeLim,'string',num2str(handles.Parameters.BPChangeLim));
   set(handles.EditHRChangeLim,'string',num2str(handles.Parameters.HRChangeLim));

   
   set(handles.EditMaxBP,'string',num2str(handles.Parameters.maxBP));
   set(handles.EditMinBP,'string',num2str(handles.Parameters.minBP));
   
   set(handles.EditPATThreshold,'string',num2str(handles.Parameters.cndPAT));
   set(handles.EditEpochSize,'string',num2str(handles.Parameters.EpochSize));
   set(handles.EditEpochStep,'string',num2str(handles.Parameters.EpochStep));

function Parameters = GetDefaultComputationParameter
   Parameters.Delay = 1;
   Parameters.SegLen = 3;
   Parameters.R2Lim = 0.8;
   Parameters.SlopeLim = 100;
   Parameters.BPChangeLim = 40;
   Parameters.HRChangeLim = 40;   
   Parameters.maxBP = 275;
   Parameters.minBP = 20;
   Parameters.cndPAT = 150; %ms   
   Parameters.EpochSize = 2*60; % Spectral BRS computational window
   Parameters.EpochStep = 2*60; %2 minute time-step

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
function varargout = EDF_Viewer(varargin)
   % EDF_VIEWER M-file for EDF_Viewer.fig
   %      EDF_VIEWER, by itself, creates a new EDF_VIEWER or raises the existing
   %      singleton*.
   %
   %      H = EDF_VIEWER returns the handle to a new EDF_VIEWER or the handle to
   %      the existing singleton*.
   %
   %      EDF_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
   %      function named CALLBACK in EDF_VIEWER.M with the given input arguments.
   %
   %      EDF_VIEWER('Property','Value',...) creates a new EDF_VIEWER or raises the
   %      existing singleton*.  Starting from the left, property value pairs are
   %      applied to the GUI before EEGViewer_OpeningFunction gets called.  An
   %      unrecognized property name or invalid value makes property application
   %      stop.  All inputs are passed to EDF_Viewer_OpeningFcn via varargin.
   %
   %      *See GUI Optionclcs on GUIDE's ools menu.  Choose "GUI allows only one
   %      instance to run (singleton)".
   %
   % See also: GUIDE, GUIDATA, GUIHANDLES
   % Edit the above text to modify the response to help EDF_Viewer

   % Last Modified by GUIDE v2.5 20-Sep-2018 12:22:07

   % Begin initialization code - DO NOT EDIT
   gui_Singleton = 1;
   gui_State = struct('gui_Name',       mfilename, ...
       'gui_Singleton',  gui_Singleton, ...
       'gui_OpeningFcn', @EDF_Viewer_OpeningFcn, ...
       'gui_OutputFcn',  @EDF_Viewer_OutputFcn, ...
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


% --- Executes just before EDF_Viewer is made visible.
function EDF_Viewer_OpeningFcn(hObject, eventdata, handles, varargin)
   % This function has no output args, see OutputFcn.
   % hObject    handle to figure
   % eventdata  reserved - to be defined in a future version of MATLAB
   % handles    structure with handles and user data (see GUIDATA)
   % varargin   command line arguments to EDF_Viewer (see VARARGIN)

   % Choose default command line output for EDF_Viewer
   handles.output = hObject;

   handles.Path = [];

   handles.WindowTime=[2 3 4 5 7 8 10 15 20 30 60 90 120 240 840];
   
   handles.EDFObj = [];

   set(handles.axes1,'xticklabel','','yticklabel','');

   assignin('base','ResultPath',[]);  
 
   if ispc
      handles.PathSeparator = '\';
   else
      handles.PathSeparator = '/';
   end;
   
   set(handles.ListHighPassFilter,'string',{'    off' '   to Hz' '2          Sec' '1          Sec'...
       '0.3       Sec' '0.2       Sec' '0.16     Sec' '0.1       Sec' '0.08     Sec' '0.053   Sec' ...
       '0.04     Sec' '0.032   Sec' '0.016   Sec' '0.008   Sec' '0.0053 Sec' '0.004   Sec'});   
   set(handles.ListHighPassFilter,'value',7);  

   handles.Display.displayIdx = 1;
   
   handles.SettlingTime = 1;
   
   % Update handles structure
   guidata(hObject, handles);

   % UIWAIT makes EDF_Viewer wait for user response (see UIRESUME)
   % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EDF_Viewer_OutputFcn(hObject, eventdata, handles)
   % varargout  cell array for returning output args (see VARARGOUT);
   % hObject    handle to figure
   % eventdata  reserved - to be defined in a future version of MATLAB
   % handles    structure with handles and user data (see GUIDATA)

   % Get default command line output from handles structure
   varargout{1} = handles.output;


function UpdateCommentsList(handles)
   if(~isempty(handles.Comments.Time) && ~isempty(handles.Comments.Text))
      Temp=[0 cumsum(handles.EDFObj.getTotalTime)];
      Temp(end)=[];

      Temp1=cell2mat(handles.Comments.Time);
      IndexStartTime = zeros(size(Temp1));
      for i=1:length(Temp)
          IndexStartTime(Temp1>=Temp(i))=i;
      end
      Temp = [];
      for i=1:length(handles.Comments.Text)
          Time = handles.Comments.Time{i}/86400;
          if get(handles.CheckBoxActualTime,'value')
              Time1 = datenum([handles.EDFObj.getStartDate '--' handles.EDFObj.getStartTime],'dd/mm/yy--HH:MM:SS');
          else
              Time1 = 0;
          end
          Time = datestr(Time+Time1,'HH:MM:SS');

          Temp{i}=[Time ' - '...
              handles.Comments.Text{i}];
      end
   else
      Temp = [];
   end;
   set(handles.ListBoxComments,'string',Temp,'value',1);
   
   
function UpdatePlots(handles)
   % Select the current axes
   axes(handles.axes1);
   cla;

   if(isempty(handles.EDFObj))
      return;
   end;

   SelectedCh=evalin('base','SelectedCh');
   displayRawData = get(handles.checkboxShowRawData,'value');

   ComTime = cell2mat(handles.Comments.Time);

   ComTime = ComTime(:)';

   numberSignal = get(handles.PopupNumberSignal,'string');
   Temp = get(handles.PopupNumberSignal,'value');
   numberSignal = strtrim(numberSignal{Temp});
   numberSignal = str2num(numberSignal);
   
   axesXLim = [0 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]+get(handles.SliderTime,'value');
   axesYLim = [0 numberSignal];

   Temp  = get(handles.PopupSensitivity,'value');
   Temp1 = get(handles.PopupSensitivity,'string');
   Temp = Temp1{Temp};
   Temp =str2num(Temp(1:end-2));

   if(~isempty(handles.SelectedChMap))
      Temp1 = handles.EDFObj.getSamplingRate;
      
      % Plot first set of selected data
      hold on
      
      for i=1:axesYLim(2)
         idx = i+handles.Display.displayIdx-1;
         
         if(idx > length(handles.SelectedChMap))
            break;
         end;
         
         Time = ([1:length(handles.DataOrg{SelectedCh(idx,1)})]-1)/Temp1(SelectedCh(idx,1))+get(handles.SliderTime,'value');
         
         if displayRawData || (handles.Display.isFiltered(idx) == 0) % No filter
            Temp2 = handles.Data{idx};
            dispColor = [0 0 0.5];
         else
            Temp2 = filter(handles.Display.TotalFilterB{idx},handles.Display.TotalFilterA{idx},handles.Data{idx});
            dispColor = [0 0 1];      
         end;
      
Temp = handles.EDFObj.getSegmentStartTime;
DataStart = get(handles.SliderTime,'value') - Temp(handles.SelSegment); %Relative to the beginning of segment!

if((DataStart - handles.SettlingTime) > 0)
   Time = Time - handles.SettlingTime;
else
   Time = Time - DataStart;
end;        
         
         Temp2 = 0.8*(Temp2 - handles.Display.Offset(idx))/handles.Display.Scale(idx);           
         
         line([Time(1) Time(end)],[1 1]*axesYLim(2) - i + 0.5 + 0.4,'Color',[0.5 0.5 0.5]);
         line([Time(1) Time(end)],[1 1]*axesYLim(2) - i + 0.5 - 0.4,'Color',[0.5 0.5 0.5]);
         text(axesXLim(2),axesYLim(2) - i + 0.5 + 0.3,[num2str(handles.Display.Offset(idx) + 0.5*handles.Display.Scale(idx)) ' ' handles.SelectedChUnit{idx}],...
            'Color','r','HorizontalAlignment','right','FontWeight','bold');
         text(axesXLim(2),axesYLim(2) - i + 0.5 - 0.3,[num2str(handles.Display.Offset(idx) - 0.5*handles.Display.Scale(idx)) ' ' handles.SelectedChUnit{idx}],...
            'Color','r','HorizontalAlignment','right','FontWeight','bold');
         plot(Time,Temp2 + axesYLim(2) - i + 0.5,'Color',dispColor);
      end      
  
      xlim(axesXLim);
      ylim(axesYLim);

      Temp = [axesYLim(1)+0.5:1:axesYLim(2)-0.5];      
      Temp1 = min(axesYLim(2),length(handles.SelectedChMap));
      set(gca,'yTick',Temp(end-Temp1+1:end));      
      set(gca,'yTickLabel',handles.SelectedChMap([Temp1:-1:1]+handles.Display.displayIdx-1),'TickLabelInterpreter','none');

      if get(handles.radiobuttonGridLines,'value')
         grid on;
      else
         grid off;
      end
      set(gca,'FontWeight','bold','xTickLabel','')
      hold off
      ylabel('')

      % Select the comments that is closest to the middle of plot
      Temp = get(handles.SliderTime,'value')+handles.WindowTime(get(handles.PopMenuWindowTime,'value'))/2;
      [Min Index]=min(abs(cell2mat(handles.Comments.Time)-Temp));
      set(handles.ListBoxComments,'value',Index);

%       % plot scale bar
%       Temp=get(handles.axes1,'xlim');
%       Start=(Temp(2)-Temp(1))*37/40+Temp(1);
%       hold on
%       plot([Start Start],[0 -Sen/4]-Sen/8-(size(SelectedCh,1)-1)*Sen,'color','k','linewidth',4)
%       Start = Start+(Temp(2)-Temp(1))/Temp1(1);
%       text(Start,-Sen/4-(size(SelectedCh,1)-1)*Sen,[num2str(Sen/4) ' uV'],'FontWeight','bold');
%       hold off
   else
      set(gca,'yTick',[]);
      set(gca,'yTickLabel',[]);
   end;

   SetAbsTime(handles);

   %--------------------------------------------------------------------------
   Temp = get(handles.radiobuttonCommentsDispAll,'value');
   Temp1 = get(handles.radiobuttonCommentsDispMarker,'value');
   Temp2 = get(handles.radiobuttonCommentsDispOff,'value');

   %Plot comments line
   if(~isempty(ComTime)) && (Temp || Temp1)
      axes(handles.axes1)
      hold on
      % plot comments line
      line([ComTime;ComTime],[ComTime*0+axesYLim(1);ComTime*0+axesYLim(2)],...
          'color',[255 0 0]/255,'LineWidth',1)
      hold off
   end;

   % plot comments text
   if(Temp)
      Temp1 = 0;
      Temp = get(handles.axes1,'XLim');
      
      for i=1:length(handles.Comments.Text)
         if((ComTime(i) >= Temp(1)) && (ComTime(i) <= Temp(2)))
            Temp1 = 1-Temp1;
            if(Temp1)
               h = text(ComTime(i),axesYLim(1), handles.Comments.Text{i},'FontWeight','bold','VerticalAlignment','top');
            else
               h = text(ComTime(i),axesYLim(2), handles.Comments.Text{i},'FontWeight','bold','VerticalAlignment','top','HorizontalAlignment','right');
            end;
            set(h, 'rotation', 90); 
         end;
      end;
   end;
   %--------------------------------------------------------------------------
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function handles = FileRead(handles)
    Temp = handles.EDFObj.getSegmentStartTime;
    DataStart = get(handles.SliderTime,'value') - Temp(handles.SelSegment); %Relative to the beginning of segment!
    DataLength = handles.WindowTime(get(handles.PopMenuWindowTime,'value'));

if((DataStart - handles.SettlingTime) > 0)
   DataStart = DataStart - handles.SettlingTime;
   DataLength = DataLength + handles.SettlingTime;
else
   DataStart = 0;
   DataLength = DataLength + (handles.SettlingTime - DataStart);   
end;
    
    % Additional code to not extract data from non-display channel (Speed up unless user want to display all channels)
    Temp = evalin('base','SelectedCh');
    Temp1 = unique(Temp); %Get distinct channel  
    Temp = find(Temp1); 
    Temp1 = Temp1(Temp); %Remove 0 from index

    handles.DataOrg = handles.EDFObj.FileRead(DataStart,DataLength,Temp1,handles.SelSegment); 

    SelectedCh=evalin('base','SelectedCh');

    handles.Data=[];

    % construct the selected referential and differential channels
    for i=1:size(SelectedCh,1)
        if SelectedCh(i,2)==0
            % referential
            handles.Data{i}=handles.DataOrg{SelectedCh(i,1)};
        else
           % differential
           if(length(handles.DataOrg{SelectedCh(i,1)}) == length(handles.DataOrg{SelectedCh(i,2)}))
               handles.Data{i} = handles.DataOrg{SelectedCh(i,1)}-handles.DataOrg{SelectedCh(i,2)};
           else
               % Uneven sampling channel. Change data into 1st channel sampling rate.
               Temp1 = [0:1/length(handles.DataOrg{SelectedCh(i,1)}):1-1/length(handles.DataOrg{SelectedCh(i,1)})];
               Temp2 = [0:1/length(handles.DataOrg{SelectedCh(i,2)}):1-1/length(handles.DataOrg{SelectedCh(i,2)})];
               Temp = interp1(Temp2,handles.DataOrg{SelectedCh(i,2)},Temp1); 
              
               handles.Data{i} = handles.DataOrg{SelectedCh(i,1)}-Temp;
            end;
        end
    end

    
% --- Executes on selection change in PopMenuWindowTime.
function PopMenuWindowTime_Callback(hObject, eventdata, handles)
   % Hints: contents = get(hObject,'String') returns PopMenuWindowTime contents as cell array
   %        contents{get(hObject,'Value')} returns selected item from PopMenuWindowTime

   % calculate the slider maximum time
   Temp2 = [0 cumsum(handles.EDFObj.getTotalTime)];
   Temp2 = Temp2(handles.SelSegment);
   Temp1 = handles.EDFObj.getTotalTime;
   while (Temp1(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value')))<=0
       Temp=get(handles.PopMenuWindowTime,'value');
       set(handles.PopMenuWindowTime,'value',Temp-1);
   end

   TempMax=Temp1(handles.SelSegment)-...
       handles.WindowTime(get(handles.PopMenuWindowTime,'value'));


   Temp = [0 cumsum(Temp1)];
   set(handles.SliderTime,'Min',Temp(handles.SelSegment));


   if get(handles.SliderTime,'value')>(TempMax+Temp(handles.SelSegment))
       set(handles.SliderTime,'value',TempMax+Temp(handles.SelSegment))
   end
   set(handles.SliderTime,'Max',TempMax+Temp(handles.SelSegment));

   set(handles.SliderTime,'SliderStep',[1 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]/TempMax)

   handles=FileRead(handles);
   guidata(hObject,handles);
   UpdatePlots(handles)


% --- Executes on slider movement.
function SliderTime_Callback(hObject, eventdata, handles)
   % Hints: get(hObject,'Value') returns position of slider
   %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
   
   % get the slider current value and make it integer
   Temp=round(get(hObject,'value'));
   max=get(hObject,'max');
   set(hObject,'value',min(Temp,max));

   handles=FileRead(handles);
   guidata(hObject,handles);
   UpdatePlots(handles)


% --- Executes on selection change in ListBoxPatientNames.
function ListBoxFileNames_Callback(hObject, eventdata, handles)
   % Hints: contents = get(hObject,'String') returns ListBoxPatientNames contents as cell array
   %        contents{get(hObject,'Value')} returns selected item from ListBoxPatientNames
   Sel = get(handles.ListBoxFileNames,'value');

   FileName = [handles.Path handles.FileName{Sel}];

   %--------------------------------------------------------------------------
   % Get EDF File Info.
   %--------------------------------------------------------------------------
   handles.EDFObj = EDF_File_Class(FileName);%.FileInfo = EDF_FileInfo(FileName);
   handles.SelSegment = 1;
   
   %--------------------------------------------------------------------------
   % Future implementation for EDF+D
   %--------------------------------------------------------------------------
   % #For multiple segments#
   if handles.EDFObj.getNumberOfSegment>1   
       Temp1 = datenum([handles.EDFObj.getStartDate ' - ' handles.EDFObj.getStartTime],'dd/mm/yy - HH:MM:SS');
       
       for i=1:length(handles.EDFObj.getTotalTime)
           Time = Temp1 + handles.EDFObj.getSegmentStartTime/86400;
           Temp2{i} = datestr(Time,'dd/mm/yy - HH:MM:SS');
       end;
   
       set(handles.ListBoxSegments,'enable','on','string',Temp2,'value',1)
       set(handles.TextSegments,'enable','on','string',[num2str(length(handles.EDFObj.getTotalTime)) ' Segments'])
   else
       set(handles.ListBoxSegments,'enable','off','string',[])
       set(handles.TextSegments,'enable','off','string','Segment')
   end

   try
      handles.Comments = handles.EDFObj.getAnnotation;
      idx = cell2mat(handles.Comments.Time);
      [~,idx] = sort(idx);
      handles.Comments.Time = handles.Comments.Time(idx);
      handles.Comments.Text = handles.Comments.Text(idx);
   catch
      handles.Comments.Time = [];
      handles.Comments.Text = [];   
   end;
   assignin('base','ChMap',handles.EDFObj.getChMap);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Temp1 = handles.EDFObj.getTotalTime; 
   while (Temp1(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value')))<=0
       Temp=get(handles.PopMenuWindowTime,'value');
       if(Temp == 1)
          break;
       end;
       set(handles.PopMenuWindowTime,'value',Temp-1);
   end

   % set slider window time parameters
   TempMax = Temp1(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value'));
   set(handles.SliderTime,'Min',0);
   set(handles.SliderTime,'value',0);
   set(handles.SliderTime,'Max',TempMax);

   set(handles.SliderTime,'SliderStep',[1 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]/TempMax);

   SigNum = handles.EDFObj.FileInfo.NumberOfSignals;
   SelectedChMap=[];
   try
      SelectedCh=evalin('base','SelectedCh');
   catch e
      SelectedCh = [1 0];
      assignin('base','SelectedCh',SelectedCh);      
   end;
   
   if( max(max(SelectedCh)) > SigNum )
      SelectedCh = [1 0];
      assignin('base','SelectedCh',SelectedCh);      
   end;

   handles = generateChDisplaySetting(handles);
   
   %Prepare information for computational module
   assignin('base','EDFObject',handles.EDFObj);   
   
   % Plot data
   handles=FileRead(handles);
   
   %Set display index
   handles.Display.displayIdx = 1;

   guidata(hObject,handles);
   UpdateCommentsList(handles);
   UpdatePlots(handles);


% --- Executes on selection change in ListBoxComments.
function ListBoxComments_Callback(hObject, eventdata, handles)
   % Hints: contents = get(hObject,'String') returns ListBoxComments contents as cell array
   %        contents{get(hObject,'Value')} returns selected item from ListBoxComments
   Index = get(hObject,'value');

   Temp = handles.Comments.Time{Index}-handles.WindowTime(get(handles.PopMenuWindowTime,'value'))/2;

   Temp=find((cumsum(handles.EDFObj.getTotalTime)-Temp)>0);
   set(handles.ListBoxSegments,'value',Temp(1));

   % ---------------------------------------------------------------------

   Sel=get(handles.ListBoxSegments,'value');

   handles.SelSegment = Sel;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Temp1 = handles.EDFObj.getTotalTime;
   while (Temp1(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value')))<=0
       Temp=get(handles.PopMenuWindowTime,'value');
       set(handles.PopMenuWindowTime,'value',Temp-1);
   end


   % set slider window time parameters
   TempMax=Temp1(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value'));
   Temp = [0 cumsum(handles.EDFObj.getTotalTime)];
   set(handles.SliderTime,'Min',Temp(Sel));
   set(handles.SliderTime,'value',Temp(Sel));
   set(handles.SliderTime,'Max',TempMax+Temp(Sel));

   set(handles.SliderTime,'SliderStep',[1 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]/TempMax)

   % ---------------------------------------------------------------------
   Temp = handles.Comments.Time{Index}-handles.WindowTime(get(handles.PopMenuWindowTime,'value'))/2;

   if Temp<0
       Temp=0;
   end


   if Temp>get(handles.SliderTime,'Max')
       set(handles.SliderTime,'value',get(handles.SliderTime,'Max'));
   else
       set(handles.SliderTime,'value',Temp);
   end

   handles=FileRead(handles);
   guidata(hObject,handles);
   UpdatePlots(handles)


function  SetAbsTime(handles)
   Temp = get(gca,'xTick');

   if get(handles.CheckBoxActualTime,'value')
       Time = datenum([handles.EDFObj.getStartDate '--' handles.EDFObj.getStartTime],'dd/mm/yy--HH:MM:SS');
   else
       Time = 0;
   end
   Label = datestr(Temp/86400+Time,'HH:MM:SS');

   set(gca,'xTickLabel',Label);


%sec2clk.m
function [clk]=sec2clk(sec)
   %[clk]=sec2clk(sec)
   %   Input:
   %     sec: time in seconds
   %
   %   Output:
   %     clk: time format 'HH:MM:SS'
   %
   if(~isnumeric(sec) || length(sec)~=1) disp('sec input not numeric scalar');
       return; end

   Hours=floor(sec/3600);Mins=floor((sec-3600*Hours)/60);
   Secs=sec-3600*Hours-60*Mins;

   if(Hours<10) HH=['0' num2str(Hours)]; else HH=num2str(Hours); end
   if(Mins<10) MM=['0' num2str(Mins)]; else MM=num2str(Mins); end
   if(Secs<10) SS=['0' num2str(Secs)]; else SS=num2str(Secs); end

   clk=[HH ':' MM ':' SS];


% --- Executes on selection change in ListBoxSegments.
function ListBoxSegments_Callback(hObject, eventdata, handles)
   % Hints: contents = cellstr(get(hObject,'String')) returns ListBoxSegments contents as cell array
   %        contents{get(hObject,'Value')} returns selected item from ListBoxSegments
   Sel=get(hObject,'value');
   handles.SelSegment = Sel;
   assignin('base','ChMap',handles.EDFObj.getChMap);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Temp1 = handles.EDFObj.getTotalTime;
   while (Temp1(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value')))<=0
       Temp=get(handles.PopMenuWindowTime,'value');
       set(handles.PopMenuWindowTime,'value',Temp-1);
   end

   % set slider window time parameters     
    TempMax=Temp1(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value'));
    set(handles.SliderTime,'Min',handles.EDFObj.getSegmentStartTime(Sel),'value',handles.EDFObj.getSegmentStartTime(Sel));
    set(handles.SliderTime,'Max',TempMax+handles.EDFObj.getSegmentStartTime(Sel));

   set(handles.SliderTime,'SliderStep',[1 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]/TempMax)

   handles=FileRead(handles);
   guidata(hObject,handles);
   UpdatePlots(handles);

   
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
   % hObject    handle to figure1 (see GCBO)
   % eventdata  reserved - to be defined in a future version of MATLAB
   % handles    structure with handles and user data (see GUIDATA)
   if(isempty(handles.EDFObj))
      return;
   end;   
   
   Temp = get(handles.axes1,'CurrentPoint');

   xLim = get(handles.axes1,'xLim');
   yLim = get(handles.axes1,'yLim');

   if (Temp(1,1)<xLim(1)) && (Temp(1,2)>yLim(1)) && (Temp(1,2)<yLim(2))      
      numberSignal = get(handles.PopupNumberSignal,'string');
      Sel = get(handles.PopupNumberSignal,'value');
      numberSignal = strtrim(numberSignal{Sel});
      numberSignal = str2num(numberSignal);

      curClick = ceil(Temp(1,2));
      selectSignalNum = length(handles.SelectedChMap);
    
      CurrentSignal = numberSignal - curClick + 1;
      CurrentSignal = CurrentSignal + handles.Display.displayIdx - 1;
      
      if(CurrentSignal <= selectSignalNum)
         %msgbox(handles.SelectedChMap{CurrentSignal})
         %*****Unfish*****%
         %Open GUI for user to adjust display setting
         %handles.Display
         curSetting.isEEG = handles.Display.isEEG(CurrentSignal);
         curSetting.isFiltered = handles.Display.isFiltered(CurrentSignal);
         curSetting.notch50 = handles.Display.notch50(CurrentSignal);
         curSetting.notch60 = handles.Display.notch60(CurrentSignal);
         curSetting.LPFcutoff = handles.Display.LPFcutoff(CurrentSignal);
         curSetting.HPFcutoff = handles.Display.HPFcutoff(CurrentSignal);
         curSetting.Scale = handles.Display.Scale(CurrentSignal);
         curSetting.Offset = handles.Display.Offset(CurrentSignal);
         curSetting.ChName = handles.SelectedChMap{CurrentSignal};
         curSetting.Unit = handles.SelectedChUnit{CurrentSignal};
         %curSetting
         assignin('base','curSetting',curSetting);
         assignin('base','settingChange',0);
         ChannelDisplaySetting;
         uiwait;
         curSetting = evalin('base','curSetting');
         isChange = evalin('base','settingChange');
         
         if(isChange == 1)
            handles.Display.isEEG(CurrentSignal) = curSetting.isEEG;
            handles.Display.isFiltered(CurrentSignal) = curSetting.isFiltered;
            handles.Display.notch50(CurrentSignal) = curSetting.notch50;
            handles.Display.notch60(CurrentSignal) = curSetting.notch60;
            handles.Display.LPFcutoff(CurrentSignal) = curSetting.LPFcutoff;
            handles.Display.HPFcutoff(CurrentSignal) = curSetting.HPFcutoff;
            handles.Display.Scale(CurrentSignal) = curSetting.Scale;
            handles.Display.Offset(CurrentSignal) = curSetting.Offset;
            
            if(curSetting.isEEG == 1)
               handles = genEEGFilter(handles);
               handles = setEEGSensitivity(handles);
            else
               if (curSetting.notch50 == 1) || (curSetting.notch60 == 1) || (curSetting.LPFcutoff ~= 0) || (curSetting.HPFcutoff ~= 0)
                  FsAll = handles.EDFObj.getSamplingRate;
                  handles.Display.isFiltered(CurrentSignal) = 1;
                  [handles.Display.TotalFilterB{CurrentSignal}, handles.Display.TotalFilterA{CurrentSignal}] = genFilter(curSetting.notch50,curSetting.notch60,curSetting.LPFcutoff,curSetting.HPFcutoff,FsAll(CurrentSignal));
               else
                  handles.Display.TotalFilterB{CurrentSignal} = 1;
                  handles.Display.TotalFilterA{CurrentSignal} = 1;
                  handles.Display.isFiltered(CurrentSignal) = 0;
               end;
            end;            

            guidata(hObject,handles);
            UpdatePlots(handles);            
         end;
      end;
   end


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
   % hObject    handle to figure1 (see GCBO)
   % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
   %	Key: name of the key that was pressed, in lower case
   %	Character: character interpretation of the key(s) that was pressed
   %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
   % handles    structure with handles and user data (see GUIDATA)
   currentCharacter = get(hObject,'CurrentCharacter')+0;

   if get(handles.CheckBoxActualTime,'value')
      Time1 = [handles.EDFObj.getStartDate '--' handles.EDFObj.getStartTime];
      Time1([3,6]) = '::';
      Time1 = datenum(Time1,'dd:mm:yy--HH:MM:SS');
   else
      Time1 = 0;
   end

   if currentCharacter == 115
       % get the comment time and put in start
       Index = get(handles.ListBoxComments,'value');
       Temp = datestr(handles.Comments.Time{Index}/86400+Time1,'HH:MM:SS');
       set(handles.EditStart,'string',Temp);
       set(handles.CheckBoxEditResp,'enable','off','value',0);
   end

   if currentCharacter == 101
       % get the comment time and put in start
       Index = get(handles.ListBoxComments,'value');
       Temp = datestr(handles.Comments.Time{Index}/86400+Time1,'HH:MM:SS');
       set(handles.EditEnd,'string',Temp);
       set(handles.CheckBoxEditResp,'enable','off','value',0);
   end

   
% --- Executes on button press in CheckBoxActualTime.
function CheckBoxActualTime_Callback(hObject, eventdata, handles)
   UpdateCommentsList(handles)
   UpdatePlots(handles)


function PopupSensitivity_Callback(hObject, eventdata, handles)
   handles = setEEGSensitivity(handles);
   guidata(hObject,handles);
   UpdatePlots(handles);

   
% --- Executes on button press in radiobuttonCommentsDispAll.
function radiobuttonCommentsDispAll_Callback(hObject, eventdata, handles)
   UpdatePlots(handles);

   
% --- Executes on button press in radiobuttonCommentsDispMarker.
function radiobuttonCommentsDispMarker_Callback(hObject, eventdata, handles)
   UpdatePlots(handles);

   
% --- Executes on button press in radiobuttonCommentsDispOff.
function radiobuttonCommentsDispOff_Callback(hObject, eventdata, handles)
   UpdatePlots(handles);

   
% --- Executes on button press in radiobuttonGridLines.
function radiobuttonGridLines_Callback(hObject, eventdata, handles)
   UpdatePlots(handles);
   
   
% --------------------------------------------------------------------
function menuPath_Callback(hObject, eventdata, handles)
   Temp = uigetdir(handles.Path);   
   
   if(length(Temp) ~= 1)
      handles.Path = Temp;
      handles.Path = [handles.Path handles.PathSeparator];
      Temp = dir([handles.Path '*.EDF']);
      handles.FileName=[];

      for i=1:length(Temp)
         handles.FileName{i}= Temp(i).name;
      end

      Temp = [];
      TimeList = [];
      for i=1:length(handles.FileName)
         Temp{i} = handles.FileName{i};

         Fid = fopen([handles.Path Temp{i}],'r');

         % EDF Date time location
         fseek(Fid,8+80+80,'bof');
         Temp1 = char(fread(Fid,[1 16],'char'));

         try
            Temp1 = [Temp1(1:2) '/' Temp1(4:5) '/' Temp1(7:8) ' ' Temp1(9:10) ':' Temp1(12:13) ':' Temp1(15:16)];
            Temp{i} = [Temp{i} ' ' Temp1];
            TimeList(i) = datenum(Temp1,'dd/mm/yy HH:MM:SS');
         catch
         end;
         
         fclose('all');
      end
      [~,idx] = sort(TimeList);
      Temp = Temp(idx);
      handles.FileName = handles.FileName(idx);

      set(handles.ListBoxFileNames,'string',Temp,'value',1);

      set(handles.textPath,'String',handles.Path);

      %Clear plot
      cla(handles.axes1,'reset');
      set(handles.axes1,'yTickLabel','','xTickLabel','');

      %Clear comment
      handles.Comments.Time = [];
      handles.Comments.Text = [];   

      UpdateCommentsList(handles);
      
      guidata(hObject,handles);
   end;

   
% --- Executes on button press in checkboxShowRawData.
function checkboxShowRawData_Callback(hObject, eventdata, handles)
   UpdatePlots(handles);


% --------------------------------------------------------------------
function menuSelectCh_Callback(hObject, eventdata, handles)
   assignin('base','UpdateChannelListNumber',1);
   ChSelection;

   handles = generateChDisplaySetting(handles);   
   handles = FileRead(handles);

   guidata(hObject,handles);
   setSliderPlot(handles);
   UpdatePlots(handles);
   

function handles = generateChDisplaySetting(handles)
   %Load current montage
   SelectedCh=evalin('base','SelectedCh');

   SelectedChMap = {};
   SelectedChUnit = {};
   Temp = handles.EDFObj.getChMap;
   Temp1 = handles.EDFObj.getPhysicalUnit;
   for i=1:size(SelectedCh,1)
       if SelectedCh(i,2)==0
           SelectedChMap{i,1} = Temp{SelectedCh(i,1)};
           SelectedChUnit{i} = strtrim(Temp1{SelectedCh(i,1)});
       else
           SelectedChMap{i,1} = [Temp{SelectedCh(i,1)} '-' Temp{SelectedCh(i,2)}];
           
           if strcmp(strtrim(Temp1{SelectedCh(i,1)}),strtrim(Temp1{SelectedCh(i,2)}))
              SelectedChUnit{i} = strtrim(Temp1{SelectedCh(i,1)});
           else
              SelectedChUnit{i} = [strtrim(Temp1{SelectedCh(i,1)}) '-' strtrim(Temp1{SelectedCh(i,2)})];
           end;
       end
   end;
   handles.SelectedChMap=SelectedChMap;
   handles.SelectedChUnit=SelectedChUnit;
   
   %Setup display setting
   Temp = handles.EDFObj.getPhysicalUnit;
   Pmax = handles.EDFObj.getPhysicalMaximum;
   Pmin = handles.EDFObj.getPhysicalMinimum;
   handles.Display = [];
   handles.Display.displayIdx = 1;    
   for i=1:size(SelectedCh,1)
      handles.Display.isEEG(i) = 0;
      handles.Display.isFiltered(i) = 0;
      handles.Display.TotalFilterB{i} = 1;
      handles.Display.TotalFilterA{i} = 1;          
      handles.Display.notch50(i) = 0;
      handles.Display.notch60(i) = 0;
      handles.Display.LPFcutoff(i) = 0;
      handles.Display.HPFcutoff(i) = 0;
      Range = Pmax(SelectedCh(i,1)) - Pmin(SelectedCh(i,1));
      if(Range == 0)
         Range = 1;
      end;
      handles.Display.Scale(i) = Range;
      handles.Display.Offset(i) = Range/2; 
      
      curUnit = strtrim(Temp{SelectedCh(i,1)});
      if(~isempty(curUnit)) &&( strcmp(lower(curUnit(end)),'v') )
         Temp1 = lower(SelectedChMap{i});
         idx = strfind(Temp1,'ekg');
         idx = [idx strfind(Temp1,'ecg')];
         idx = [idx strfind(Temp1,'thor')];
         idx = [idx strfind(Temp1,'abd')];
         idx = [idx strfind(Temp1,'chest')];
         idx = [idx strfind(Temp1,'ther')];
         
         if(isempty(idx)) %These are EEG channel
            handles.Display.isEEG(i) = 1;        
            handles.Display.isFiltered(i) = 1;
            handles.Display.Scale(i) = 0;
            handles.Display.Offset(i) = 0;
         else
            handles.Display.Scale(i) = 500;
            handles.Display.Offset(i) = 0;
         end;
      end;
   end;
   
   %Setup Filter and display setting for all channels
   handles = genEEGFilter(handles);
   %Set sensitivity for EEG signals
   handles = setEEGSensitivity(handles);
   
   
function handles = setEEGSensitivity(handles)
   if(isempty(handles.EDFObj))
      return;
   end;

   %Load current montage
   SelectedCh=evalin('base','SelectedCh');
   
   Temp = get(handles.PopupSensitivity,'string');
   Sen = get(handles.PopupSensitivity,'value');
   Sen = strtrim(Temp{Sen});
   Sen = strtrim(Sen(1:end-2));
   Sen = str2num(Sen);

   %If we have the right data, the number of sampling rate in FsList should be 1
   for i = 1:size(SelectedCh,1)
      if(handles.Display.isEEG(i) == 1)
         handles.Display.Scale(i) = Sen;
         handles.Display.Offset(i) = 0;       
      end;
   end;

   
function handles = genEEGFilter(handles)
   % notch filter
   notch50 = get(handles.CheckNotch50,'value');
   notch60 = get(handles.CheckNotch60,'value');

   % low passs filtering
   LP_cutoff = 0;
   if get(handles.ListLowPassFilter,'value')>1
      LP_cutoff=get(handles.ListLowPassFilter,'value');
      Temp1=get(handles.ListLowPassFilter,'string');
   
      LP_cutoff = strtrim(Temp1{LP_cutoff});
      LP_cutoff = str2num(LP_cutoff(1:end-2));
   end;   
   
   % High pass filtering
   HP_cutoff = 0;
   if get(handles.ListHighPassFilter,'value')>2
       HP_cutoff=get(handles.ListHighPassFilter,'value');
       Temp1=get(handles.ListHighPassFilter,'string');

       HP_cutoff = strtrim(Temp1{HP_cutoff});
       HP_Type = HP_cutoff(end-2:end);
       HP_cutoff = str2num(HP_cutoff(1:end-3));
       
       % High pass filter type
       % 1 : Time constant second
       % 2 : frequency Hz
       %
       % design the filter according to filter type
       if strcmp(HP_Type,'Sec')         
           HP_cutoff=1/(2*pi*HP_cutoff);
       end
   end;      
   
   FsAll = handles.EDFObj.getSamplingRate;
   SelectedCh=evalin('base','SelectedCh');
   FsList = unique(FsAll(SelectedCh(:,1)));
   
   for i = 1:length(FsList)
      [TotalFilterB{i}, TotalFilterA{i}] = genFilter(notch50,notch60,LP_cutoff,HP_cutoff,FsList(i));
   end;
   
   %If we have the right data, the number of sampling rate in FsList should be 1
   for i = 1:size(SelectedCh,1)
      if(handles.Display.isEEG(i) == 1)
         for j = 1:length(FsList)
            if (FsAll(SelectedCh(i,1)) == FsList(j))
               handles.Display.isFiltered(i) = 1;
               handles.Display.TotalFilterB{i} = TotalFilterB{j};
               handles.Display.TotalFilterA{i} = TotalFilterA{j};
               
               % Detail display setting so that user can adjust them
               % manually later on
               handles.Display.notch50(i) = notch50;
               handles.Display.notch60(i) = notch60;
               if(isempty(LP_cutoff))
                  handles.Display.LPFcutoff(i) = 0;
               else
                  handles.Display.LPFcutoff(i) = LP_cutoff;
               end;
               if(isempty(HP_cutoff))
               handles.Display.HPFcutoff(i) = 0;
               else
                  handles.Display.HPFcutoff(i) = HP_cutoff;
               end;
               break;
            end;
         end;         
      end;
   end;

function [TotalFilterB, TotalFilterA] = genFilter(notch50,notch60,LP_cutoff,HP_cutoff,Fs)   
   % The filtering is beging done in just one step
   % whenever each of the notch, high pass or low pass is used the calculated
   % filter paramters is convolved with the TotalFilterA and TotalFilterB
   TotalFilterA=1;
   TotalFilterB=1;

   % notch filter
   if (notch60 == 1) && (Fs > 120)          
      wo = 60/(Fs/2);  bw = wo/35;
      [B,A] = iirnotch(wo,bw); % design the notch filter for the given sampling rate

      TotalFilterA = conv(TotalFilterA,A);
      TotalFilterB = conv(TotalFilterB,B);
   end;
   if (notch50 == 1) && (Fs > 100)     
      wo = 50/(Fs/2);  bw = wo/35; % design the notch filter for the given sampling rate
      [B,A] = iirnotch(wo,bw);

      TotalFilterA = conv(TotalFilterA,A);
      TotalFilterB = conv(TotalFilterB,B);
   end

   % low passs filtering
   if (LP_cutoff ~= 0) && (Fs > 2*LP_cutoff)
      [B,A] = butter(2,LP_cutoff/Fs*2,'low');
      TotalFilterA = conv(TotalFilterA,A);
      TotalFilterB = conv(TotalFilterB,B);
   end

   % High pass filtering
   if (HP_cutoff ~= 0) && (Fs > 2*HP_cutoff)
       [B,A] = butter(1,HP_cutoff/Fs*2,'high');

       TotalFilterA = conv(TotalFilterA,A);
       TotalFilterB = conv(TotalFilterB,B);
   end;   
   
   
% --- Executes on button press in CheckNotch50.
function CheckNotch50_Callback(hObject, eventdata, handles)
   handles = genEEGFilter(handles);
   UpdatePlots(handles);
   guidata(hObject,handles);

   
% --- Executes on button press in CheckNotch60.
function CheckNotch60_Callback(hObject, eventdata, handles)
   handles = genEEGFilter(handles);
   UpdatePlots(handles);
   guidata(hObject,handles);

   
% --- Executes on selection change in ListHighPassFilter.
function ListHighPassFilter_Callback(hObject, eventdata, handles)
   Sel = get(handles.ListHighPassFilter,'value');
   if Sel ~= 2
      handles = genEEGFilter(handles);
      UpdatePlots(handles);
      guidata(hObject,handles);
   else
      Temp = get(handles.ListHighPassFilter,'string');
      Temp = Temp{Sel};
      if strcmp(Temp,'   to Hz')
         set(hObject,'string',{'    off' '   to Sec' '   0.1 Hz' '   0.2 Hz' '   0.3 Hz'...
             '   0.5 Hz' '   0.8 Hz' '   1    Hz' '   1.6 Hz' '   2    Hz' '   4    Hz' ...
             '   5    Hz' ' 10    Hz' ' 20    Hz' ' 30    Hz' ' 40    Hz'});
      else
         set(hObject,'string',{'    off' '   to Hz' '2          Sec' '1          Sec'...
             '0.3       Sec' '0.2       Sec' '0.16     Sec' '0.1       Sec' '0.08     Sec' '0.053   Sec' ...
             '0.04     Sec' '0.032   Sec' '0.016   Sec' '0.008   Sec' '0.0053 Sec' '0.004   Sec'});
      end;
   end;

   
% --- Executes on selection change in ListLowPassFilter.
function ListLowPassFilter_Callback(hObject, eventdata, handles)
   handles = genEEGFilter(handles);
   UpdatePlots(handles);
   guidata(hObject,handles);


% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
    Sel = get(handles.PopupSensitivity,'value');
    Temp = get(handles.PopupSensitivity,'String');
    Temp = length(Temp);
    
    if(eventdata.VerticalScrollCount == -1) %Up
       Sel = max(1,Sel-1);
    elseif(eventdata.VerticalScrollCount == 1) %Down
       Sel = min(Temp,Sel+1); 
    end;
    set(handles.PopupSensitivity,'value',Sel);
    
   handles = setEEGSensitivity(handles);
   guidata(hObject,handles);
   UpdatePlots(handles);   


% --- Executes on selection change in PopupNumberSignal.
function PopupNumberSignal_Callback(hObject, eventdata, handles);
   if(isempty(handles.EDFObj))
      return;
   end;
   
   setSliderPlot(handles);
   
   %Reset Display index
   handles.Display.displayIdx = 1;     
   
   guidata(hObject, handles);   
   UpdatePlots(handles); 


% --- Executes on slider movement.
function SliderPlot_Callback(hObject, eventdata, handles)
   val = round(get(hObject,'value'));
   max = get(hObject,'Max');
   set(hObject,'value',val)
   
   handles.Display.displayIdx = max - val + 1;     
   % Update handles structure
   guidata(hObject, handles);
   UpdatePlots(handles); 
   

function setSliderPlot(handles)
   %Enable/Disable "handles.SliderPlot"
   sel = get(handles.PopupNumberSignal,'value');
   DisplayNum = get(handles.PopupNumberSignal,'string');
   DisplayNum = str2num(DisplayNum{sel});
   SignalNum = length(handles.SelectedChMap);

   if(SignalNum > DisplayNum)
      set(handles.SliderPlot,'Min',1);      
      set(handles.SliderPlot,'Max',SignalNum-DisplayNum+1);
      set(handles.SliderPlot,'value',SignalNum-DisplayNum+1);
      set(handles.SliderPlot,'SliderStep',[1 1]/(SignalNum-DisplayNum));
      set(handles.SliderPlot,'Enable','on');
   else
      set(handles.SliderPlot,'Enable','off');
   end;


% --------------------------------------------------------------------


% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)
% hObject    handle to menuExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   close;
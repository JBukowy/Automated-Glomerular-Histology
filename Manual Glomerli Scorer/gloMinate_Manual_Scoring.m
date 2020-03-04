function varargout = gloMinate_Manual_Scoring(varargin)
% This GUI is to assist in the manual scoring of glomeruli found using the
% automated glomeruli localization method.
%
% Copyright (C) <2017>  <John D. Bukowy>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% GLOMINATE_MANUAL_SCORING MATLAB code for gloMinate_Manual_Scoring.fig
%      GLOMINATE_MANUAL_SCORING, by itself, creates a new GLOMINATE_MANUAL_SCORING or raises the existing
%      singleton*.
%
%      H = GLOMINATE_MANUAL_SCORING returns the handle to a new GLOMINATE_MANUAL_SCORING or the handle to
%      the existing singleton*.
%
%      GLOMINATE_MANUAL_SCORING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLOMINATE_MANUAL_SCORING.M with the given input arguments.
%
%      GLOMINATE_MANUAL_SCORING('Property','Value',...) creates a new GLOMINATE_MANUAL_SCORING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gloMinate_Manual_Scoring_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gloMinate_Manual_Scoring_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gloMinate_Manual_Scoring

% Last Modified by GUIDE v2.5 11-Sep-2017 11:37:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gloMinate_Manual_Scoring_OpeningFcn, ...
                   'gui_OutputFcn',  @gloMinate_Manual_Scoring_OutputFcn, ...
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


% --- Executes just before gloMinate_Manual_Scoring is made visible.
function gloMinate_Manual_Scoring_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gloMinate_Manual_Scoring (see VARARGIN)

% Choose default command line output for gloMinate_Manual_Scoring
handles.output = hObject;
handles.sessioncounter = 0;
set(handles.pb_load,'enable','on');
set(handles.pb_register,'enable','off');
set(handles.ax_glom,'visible','off');
set(handles.ax_glom_ss1,'visible','off');
set(handles.ax_glom_ss2,'visible','off');

handles.responseguide = {0 1 2 3 4 'N/A'};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gloMinate_Manual_Scoring wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gloMinate_Manual_Scoring_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_register.
function pb_register_Callback(hObject, eventdata, handles)
% hObject    handle to pb_register (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



responder(1) = get(handles.rb_zero,'value');
responder(2) = get(handles.rb_one,'value');
responder(3) = get(handles.rb_two,'value');
responder(4) = get(handles.rb_three,'value');
responder(5) = get(handles.rb_four,'value');
responder(6) = get(handles.rb_ng,'value');

handles.response(handles.registercounter) = handles.responseguide((responder==1));

switch get(handles.cb_rand90,'Value')
    case 0
        drawnow

        if handles.registercounter == length(handles.smim)

%             outputheader = {'Number', 'Distance', 'Score'};
%             outputcollector(:,1) = num2cell(1:handles.registercounter);
%             outputcollector(:,2) = handles.distance;


%             fullfilename = [fullfile(handles.PathName,sprintf('Kidney %s - Analyzed',handles.FileName(1:end-4))),'.xls'];

            cla(handles.ax_glom)
            cla(handles.ax_glom_ss1)
            cla(handles.ax_glom_ss2)
            set(handles.ax_glom,'visible','off')
            set(handles.ax_glom_ss1,'visible','off')
            set(handles.ax_glom_ss2,'visible','off')
            set(handles.pb_load,'enable','on');
            set(handles.pb_register,'enable','off');
            set(handles.text_current,'string','Load kidney to begin...');

            drawnow

%             xlswrite(fullfilename,[outputheader; outputcollector]);
            output = handles.output;
            output(:,end+1) = handles.response;
            filename = handles.FileName;
            save(filename,'output');

            handles.smim = {};
            handles.distance = {};
            handles.response = {};
            set(handles.cb_rand90,'Enable','on')
            set(handles.tx_count,'String',[])
            clear outputcollector

        end

        if handles.registercounter < length(handles.smim)
            handles.registercounter = handles.registercounter + 1;
            set(handles.tx_count,'String',sprintf('# %i out of %i',handles.registercounter,length(handles.smim)));
            imshow(handles.smim{handles.registercounter},'parent',handles.ax_glom);
            set(handles.txt_pred_score,'string',handles.pred_scores(handles.registercounter));
            imshow(handles.smim_ss{handles.registercounter}(:,:,1),[],'parent',handles.ax_glom_ss1);
            imshow(handles.smim_ss{handles.registercounter}(:,:,2),[],'parent',handles.ax_glom_ss2);
        end

        drawnow

%     case 1
%
%         drawnow
%
%         if handles.registercounter == 140
%
%             outputheader = {'Number', 'Distance', 'Score'};
%             outputcollector(:,1) = num2cell(handles.index(1:140));
%             outputcollector(:,2) = handles.distance(handles.index(1:140));
%             outputcollector(:,3) = handles.response;
%
%             fullfilename = [fullfile(handles.PathName,sprintf('Kidney %s - Analyzed',handles.FileName(1:end-4))),'.xls'];
%
%             cla(handles.ax_glom)
%             set(handles.ax_glom,'visible','off')
%             set(handles.pb_load,'enable','on');
%             set(handles.pb_register,'enable','off');
%             set(handles.text_current,'string','Load kidney to begin...');
%
%             drawnow
%
%             xlswrite(fullfilename,[outputheader; outputcollector]);
%
%             handles.smim = {};
%             handles.distance = {};
%             handles.response = {};
%             set(handles.cb_rand90,'Enable','on')
%             set(handles.tx_count,'String',[])
%             clear outputcollector
%
%         end
%
%         if handles.registercounter < 140
%             handles.registercounter = handles.registercounter + 1;
%             set(handles.tx_count,'String',sprintf('# %i out of %i',handles.registercounter,140));
%             imshow(handles.smim{handles.registercounter},'parent',handles.ax_glom);
%             set(handles.txt_pred_score,'string',handles.pred_scores(handles.registercounter));
%             imshow(handles.smim_ss{handles.registercounter}(:,:,1),[],'parent',handles.ax_glom_ss1);
%             imshow(handles.smim_ss{handles.registercounter}(:,:,2),[],'parent',handles.ax_glom_ss2);
%         end

end
        drawnow



guidata(hObject,handles)


% --- Executes on button press in pb_load.
function pb_load_Callback(hObject, eventdata, handles)
% hObject    handle to pb_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.ax_glom)
set(handles.ax_glom,'visible','off');

set(handles.pb_load,'enable','off');
set(handles.text_current,'visible','off');
set(handles.pb_register,'enable','off')

clear handles.datacollect
sessioncounter = handles.sessioncounter + 1;

handles.registercounter = 1;

warning off

if sessioncounter == 1
    [FileName,PathName,FilterIndex] = uigetfile('.mat');
elseif sessioncounter > 1
    PreviousPathName = handles.PathName;
    [FileName,PathName,FilterIndex] = uigetfile('.mat','Image Selector',PreviousPathName);
end

warning on

if isequal(FileName,0)

else

load(fullfile(PathName,FileName),'output');
% Current Kidney Format
% CK(:,1) = smim / small images
% CK(:,2) = resolved distance to edge
% CK(:,3) = border location / index
% CK(:,4) = corresponding glomerular position (absolute)
handles.output = output;
handles.smim = output(:,1);
handles.smim_ss = output(:,2);
set(handles.tx_count,'String',sprintf('# %i out of %i',handles.registercounter,length(handles.smim)));

set(handles.cb_rand90,'Enable','off')

if get(handles.cb_rand90,'Value') == 1
    handles.index = randperm(size(handles.smim,1));
    handles.smim = handles.smim(handles.index);
    set(handles.tx_count,'String',sprintf('#\r %i\r out of\r %i',handles.registercounter,140));
end

handles.distance = output(:,3);

% May need to change this for future use
if length(size(output{1,5})) > 2
handles.pred_scores = round(squeeze(output{1,5}));
handles.output(:,5) = num2cell(round(squeeze(output{1,5})));
else
    handles.pred_scores = output(:,5);
    handles.output(:,5) = output(:,5);
end

handles.PathName = PathName;
handles.FileName = FileName;
handles.fullfilename = fullfile(PathName,FileName);
handles.sessioncounter = sessioncounter;

%Very cludgey
% for i = 1:length(handles.distance)
%     handles.distance{i} = (handles.distance{i}*.65)/1000;
% end

set(handles.ax_glom,'visible','on');
set(handles.ax_glom_ss1,'visible','on');
set(handles.ax_glom_ss2,'visible','on');
set(handles.text_current,'string',sprintf('Kidney Loaded: %s',FileName));
set(handles.text_current,'visible','on');
set(handles.pb_register,'enable','on');
set(handles.txt_pred_score,'string',handles.pred_scores(1));
imshow(handles.smim{1},'parent',handles.ax_glom);
imshow(handles.smim_ss{1}(:,:,1),[],'parent',handles.ax_glom_ss1);
imshow(handles.smim_ss{1}(:,:,2),[],'parent',handles.ax_glom_ss2);

drawnow

end




guidata(hObject,handles)


% --- Executes on button press in cb_rand90.
function cb_rand90_Callback(hObject, eventdata, handles)
% hObject    handle to cb_rand90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_rand90


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pb_back.
function pb_back_Callback(hObject, eventdata, handles)
% hObject    handle to pb_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
            handles.registercounter = handles.registercounter - 1;
            set(handles.tx_count,'String',sprintf('# %i out of %i',handles.registercounter,length(handles.smim)));
            imshow(handles.smim{handles.registercounter},'parent',handles.ax_glom);
            set(handles.txt_pred_score,'string',handles.pred_scores(handles.registercounter));
            imshow(handles.smim_ss{handles.registercounter}(:,:,1),[],'parent',handles.ax_glom_ss1);
            imshow(handles.smim_ss{handles.registercounter}(:,:,2),[],'parent',handles.ax_glom_ss2);
            drawnow


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
  case '1'

    set(handles.rb_zero,'Value',0);
    set(handles.rb_one,'Value',1);
    set(handles.rb_two,'Value',0);
    set(handles.rb_three,'Value',0);
    set(handles.rb_four,'Value',0);
    set(handles.rb_ng,'Value',0);
    drawnow

    pb_register_Callback(hObject, eventdata, handles);

  case '2'

    set(handles.rb_zero,'value',0);
    set(handles.rb_one,'value',0);
    set(handles.rb_two,'value',1);
    set(handles.rb_three,'value',0);
    set(handles.rb_four,'value',0);
    set(handles.rb_ng,'value',0);
    drawnow

    pb_register_Callback(hObject, eventdata, handles);

  case '3'

    set(handles.rb_zero,'value',0);
    set(handles.rb_one,'value',0);
    set(handles.rb_two,'value',0);
    set(handles.rb_three,'value',1);
    set(handles.rb_four,'value',0);
    set(handles.rb_ng,'value',0);
    drawnow

    pb_register_Callback(hObject, eventdata, handles);

  case '4'

    set(handles.rb_zero,'value',0);
    set(handles.rb_one,'value',0);
    set(handles.rb_two,'value',0);
    set(handles.rb_three,'value',0);
    set(handles.rb_four,'value',1);
    set(handles.rb_ng,'value',0);
    drawnow

    pb_register_Callback(hObject, eventdata, handles);

  case '0'

    set(handles.rb_zero,'value',1);
    set(handles.rb_one,'value',0);
    set(handles.rb_two,'value',0);
    set(handles.rb_three,'value',0);
    set(handles.rb_four,'value',0);
    set(handles.rb_ng,'value',0);
    drawnow

    pb_register_Callback(hObject, eventdata, handles);

    case 'q'

    set(handles.rb_zero,'value',0);
    set(handles.rb_one,'value',0);
    set(handles.rb_two,'value',0);
    set(handles.rb_three,'value',0);
    set(handles.rb_four,'value',0);
    set(handles.rb_ng,'value',1);
    drawnow

    pb_register_Callback(hObject, eventdata, handles);

end

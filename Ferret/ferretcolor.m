% FERRETCOLOR creates a matlab colormap using ferret ".spk" files
%
%      	Usage:  ferretcolor 'colormapname'
%
%       FERRETCOLOR loads in the ferret colormap "colormapname.spk"
%       and applies it to the current figure
%
%       !!!! NOTE THAT THIS PROGAM IS SYSTEM DEPENDENT AND !!!!
%       !!!! REQUIRES YOU TO SET THE PATH IN WHICH TO LOOK !!!!
%       !!!! FOR ".spk" FILES                              !!!!
%
% -----------------------------------------------------------------
%
% created by Josh Willis, 12/04/03
%

function ferretcolor(colormapname)

%%%%%%% Set This Variable %%%%%%%%%%%%
% SET "pth" TO THE PATH WHERE YOUR ".spk" FILES ARE STORED!
%JG specific computer
%pth='/usr/local/src/ferret/ppl/';
pth='/viwa/argo/dmode/sio/colormap/';
%%%%%%% Set This Variable %%%%%%%%%%%%

%%%%%%% Error Checking %%%%%%%%
% check for colormap files in the path
d=dir([pth,'*.spk']);
if isempty(d),
  disp(' ')
  disp('Error:  Can''t find ANY ferret colormaps!')
  disp('Set ''pth'' variable in THIS function!')
  which ferretcolor
  disp(' ')
  return
end

% make list of possible colors using the file names from the
% dir command
dnames=strvcat(d(:).name);
dnames=strjust(dnames,'right');dnames=dnames(:,1:end-4);
dnames=strjust(dnames,'left');

% for no input argument display possible colormap choices
%n=size(dnames,1);nn=ceil(n/3);l=size(dnames,2);
%dnames=[dnames(1:nn,:),blanks(nn)',blanks(nn)',blanks(nn)', ...
%dnames(nn+1:2*nn,:),blanks(nn)',blanks(nn)',blanks(nn)', ...
%[dnames(2*nn+1:end,:);repmat(blanks(l),[1 nn-mod(n,nn)])]];
%dnames=strvcat(' ','Available colormaps:',' ',dnames,' ');
%if nargin<1, disp(dnames),return,end

% create path name
fname=[pth,colormapname,'.spk'];

% check to see that we can find the appropriate file
dd=dir(fname);
if isempty(dd)
  disp(' ')
  disp(['Error:  Can''t find file:  ',fname])
  disp(['Make sure that ''pth'' variable is set in THIS function!'])
  which ferretcolor
  disp(dnames)
  return
end
%%%%%%% End Error Checking %%%%%%%%

%%%%%%% Actual Function %%%%%%%%
% load the ferret colors
cl=load([pth,colormapname,'.spk']);

% fix up to be matlab colormap friendly
cl=cl/100;
grid=cl(:,1);
c=interp1(grid,cl(:,2:4),[0:63]/63);

% set the colormap
colormap(c)

